#!/usr/bin/env bash
#
# Recursively fetch & rebase all git repos under a directory.
#
# Usage: git-update-all.sh [directory]
#
# If no directory is given, the current working directory is used. Repos are
# discovered up to MAX_DEPTH levels deep (default: 2).
#
# What it does for each repo:
#
#   1. Stashes any uncommitted changes (staged or unstaged).
#   2. Checks out the main branch (main or master).
#   3. Fetches all remotes and rebases onto origin/<main-branch>.
#   4. If you were on a feature branch, switches back and rebases it
#      onto the now-updated main branch.
#   5. Restores the stash.
#
# If a rebase fails, it aborts and restores the repo to its exact prior
# state (branch, commit, working tree) so you can resolve it manually.
#
# Safety:
#
#   Refuses to run against /, /home, /Users, or $HOME.
#
# Exit codes:
#
#   0  All repos updated (or skipped) successfully.
#   1  One or more repos failed and need manual attention.

set -euo pipefail

# ─── Configuration ───────────────────────────────────────────────────────────
MAX_DEPTH=2

YELLOW=$'\033[1;33m'
GREEN=$'\033[1;32m'
RED=$'\033[1;31m'
CYAN=$'\033[1;36m'
DIM=$'\033[2m'
BOLD=$'\033[1m'
RESET=$'\033[0m'

# ─── Helpers ─────────────────────────────────────────────────────────────────
info()   { printf '%s[info]%s  %s\n' "$CYAN" "$RESET" "$*"; }
ok()     { printf '%s[ok]%s    %s\n' "$GREEN" "$RESET" "$*"; }
warn()   { printf '%s[warn]%s  %s\n' "$YELLOW" "$RESET" "$*"; }
err()    { printf '%s[FAIL]%s  %s\n' "$RED" "$RESET" "$*"; }
dim()    { printf '%s        %s%s\n' "$DIM" "$*" "$RESET"; }
header() { printf '\n%s-- %s --%s\n' "$BOLD" "$*" "$RESET"; }

# ─── Counters ────────────────────────────────────────────────────────────────
declare -i total=0 updated=0 skipped=0 failed=0

# ─── Safety: resolve target directory ────────────────────────────────────────
target="${1:-.}"
target="$(cd "$target" && pwd)"

case "$target" in
  /|/home|/Users|"$HOME")
    err "Refusing to run against '$target' -- too broad. Point me at a projects directory."
    exit 1
    ;;
esac

echo ""
info "Scanning for git repos under $BOLD$target$RESET (max depth $MAX_DEPTH)..."

# ─── Find repos ──────────────────────────────────────────────────────────────
mapfile -t repos < <(
  find "$target" -maxdepth $((MAX_DEPTH + 1)) -type d -name .git 2>/dev/null \
    | sort \
    | sed 's|/\.git$||'
)

if [[ ${#repos[@]} -eq 0 ]]; then
  warn "No git repositories found."
  exit 0
fi

info "Found ${#repos[@]} repo(s)."

# ─── Process each repo ──────────────────────────────────────────────────────
for repo in "${repos[@]}"; do
  total+=1
  rel="${repo#"$target"/}"
  header "$rel"

  cd "$repo"

  # ── Remember where we are ──────────────────────────────────────────────
  orig_ref="$(git symbolic-ref --quiet HEAD 2>/dev/null || git rev-parse HEAD)"
  orig_branch="${orig_ref#refs/heads/}"
  orig_sha="$(git rev-parse HEAD)"
  did_stash=false

  dim "on branch: $orig_branch (${orig_sha:0:8})"

  # ── Determine the main branch ─────────────────────────────────────────
  main_branch=""

  for candidate in main master; do
    if git show-ref --verify --quiet "refs/heads/$candidate"; then
      main_branch="$candidate"
      break
    fi
  done

  if [[ -z "$main_branch" ]]; then
    warn "No 'main' or 'master' branch found."

    printf '%s  ► Skipped%s\n' "$YELLOW" "$RESET"

    skipped+=1
    continue
  fi

  dim "main branch: $main_branch"

  # ── Fetch ──────────────────────────────────────────────────────────────
  info "Fetching origin..."
  if ! git fetch --quiet --all --prune 2>&1; then
    err "Fetch failed."

    printf '%s  ► Failed%s\n' "$RED" "$RESET"

    failed+=1
    continue
  fi

  # ── Check if there's an upstream to rebase onto ────────────────────────
  upstream="origin/$main_branch"

  if ! git rev-parse --verify "$upstream" &>/dev/null; then
    warn "No remote tracking branch '$upstream'."

    printf '%s  ► Skipped%s\n' "$YELLOW" "$RESET"

    skipped+=1
    continue
  fi

  # ── Stash uncommitted changes if needed ────────────────────────────────
  if ! git diff --quiet || ! git diff --cached --quiet; then
    info "Stashing uncommitted changes..."

    git stash push -m "git-update-all auto-stash $(date +%Y%m%dT%H%M%S)" --quiet
    did_stash=true
  fi

  # ── Switch to main branch if necessary ─────────────────────────────────
  if [[ "$orig_branch" != "$main_branch" ]]; then
    info "Switching to $main_branch..."
    if ! git checkout "$main_branch" --quiet 2>&1; then
      err "Could not checkout $main_branch."

      if $did_stash; then git stash pop --quiet 2>/dev/null; fi

      printf '%s  ► Failed%s\n' "$RED" "$RESET"

      failed+=1
      continue
    fi
  fi

  # ── Rebase ─────────────────────────────────────────────────────────────
  info "Rebasing $main_branch onto $upstream..."
  if git rebase "$upstream" --quiet 2>&1; then
    new_sha="$(git rev-parse HEAD)"

    if [[ "$orig_sha" == "$new_sha" && "$orig_branch" == "$main_branch" ]]; then
      ok "Already up to date."
    else
      ok "Rebased: ${orig_sha:0:8} -> ${new_sha:0:8}"
    fi

    updated+=1
  else
    err "Rebase failed -- aborting and restoring previous state."
    git rebase --abort 2>/dev/null

    if [[ "$orig_branch" != "$main_branch" ]]; then
      git checkout "$orig_branch" --quiet 2>/dev/null
    fi

    if [[ "$(git rev-parse HEAD)" != "$orig_sha" ]]; then
      git reset --hard "$orig_sha" --quiet 2>/dev/null
    fi

    if $did_stash; then
      git stash pop --quiet 2>/dev/null
    fi

    did_stash=false

    warn "Repo left as it was before -- needs manual attention."
    printf '%s  ► Failed%s\n' "$RED" "$RESET"
    failed+=1
    continue
  fi

  # ── Switch back to original branch ─────────────────────────────────────
  if [[ "$orig_branch" != "$main_branch" ]]; then
    info "Returning to $orig_branch..."
    git checkout "$orig_branch" --quiet 2>&1
    info "Rebasing $orig_branch onto $main_branch..."

    if git rebase "$main_branch" --quiet 2>&1; then
      ok "Feature branch rebased onto updated $main_branch."
    else
      warn "Feature-branch rebase failed -- aborting. $orig_branch left at its old state."
      git rebase --abort 2>/dev/null
    fi
  fi

  # ── Restore stash ─────────────────────────────────────────────────────
  if $did_stash; then
    info "Restoring stashed changes..."

    if git stash pop --quiet 2>&1; then
      ok "Stash restored."
    else
      warn "Stash pop had conflicts -- changes are in the stash and working tree."
    fi
  fi

  printf '%s  ► Updated%s\n' "$GREEN" "$RESET"
done

# ─── Summary ─────────────────────────────────────────────────────────────────
echo ""
printf '%s--- Summary ---%s\n' "$BOLD" "$RESET"
printf '  Total:   %d\n' "$total"
printf '  %sUpdated: %d%s\n' "$GREEN" "$updated" "$RESET"

if ((skipped > 0)); then
  printf '  %sSkipped: %d%s\n' "$YELLOW" "$skipped" "$RESET"
fi

if ((failed > 0)); then
  printf '  %sFailed:  %d%s\n' "$RED" "$failed" "$RESET"
fi

if ((failed > 0)); then
  echo ""
  warn "Some repos need manual attention -- scroll up for details."
  exit 1
fi
