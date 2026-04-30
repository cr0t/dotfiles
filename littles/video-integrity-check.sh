#!/usr/bin/env bash

# =============================================================================
# Video Integrity Checker
# =============================================================================
#
# Usage: ./check_videos.sh [directory]
#
# If no directory is given, the current directory is used.
#
# Supported formats: mp4, mov, mkv, avi, webm, m4v, mts, m2ts
#
# Validation method: ffmpeg fully decodes each file's video and audio streams
# and discards the output (-f null -). Any decode errors are captured to the
# log. This catches:
#
#   - Corrupted or truncated frames
#   - Broken container structure (bad headers, missing index)
#   - Premature end of file / incomplete downloads
#   - Invalid codec / bitstream errors
#
# Note: This checks structural integrity only — not subjective quality
# (e.g., silence, blur, wrong content).
#
# Requires: ffmpeg (install via 'brew install ffmpeg' on macOS,
#           or 'apt install ffmpeg' on Debian/Ubuntu)
#
# Requires: bash 4+ (install via 'brew install bash' on macOS)
#
# =============================================================================

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

ERRORS_LOG="video_errors.log"
PASS=0
FAIL=0

EXTENSIONS=("mp4" "mov" "mkv" "avi" "webm" "m4v" "mts" "m2ts")

# Check bash version (mapfile requires bash 4+)
if (( BASH_VERSINFO[0] < 4 )); then
  echo "Error: bash 4+ is required (current: $BASH_VERSION)."
  echo "  macOS: brew install bash"
  echo "  Then use the installed bash: /opt/homebrew/bin/bash or /usr/local/bin/bash"
  exit 1
fi

# Check ffmpeg is available
if ! command -v ffmpeg &> /dev/null; then
  echo "Error: ffmpeg is not installed or not in PATH."
  echo "  macOS:          brew install ffmpeg"
  echo "  Debian/Ubuntu:  sudo apt install ffmpeg"
  echo "  Fedora:         sudo dnf install ffmpeg"
  exit 1
fi

TARGET_DIR="${1:-.}"

if [[ ! -d "$TARGET_DIR" ]]; then
  echo "Error: '$TARGET_DIR' is not a valid directory."
  exit 1
fi

# Build find extension args as a proper array
FIND_ARGS=()
for ext in "${EXTENSIONS[@]}"; do
  [[ ${#FIND_ARGS[@]} -gt 0 ]] && FIND_ARGS+=(-o)
  FIND_ARGS+=(-name "*.${ext}")
done

FIND_CMD=(find "$TARGET_DIR" -type f \( "${FIND_ARGS[@]}" \) ! -path '*/@__thumb/*' -print0)

rm -f "$ERRORS_LOG"
{
  echo "Date: $(date)"
  echo "Directory: $(realpath "$TARGET_DIR")"
  echo "ffmpeg: $(ffmpeg -version 2>&1 | head -1)"
  echo "---"
} >> "$ERRORS_LOG"

# Collect all matching files into an array first to avoid pipe interference
# with ffmpeg when iterating (causes filename corruption on macOS with
# non-ASCII filenames)
mapfile -d '' FILES < <("${FIND_CMD[@]}")

if [[ ${#FILES[@]} -eq 0 ]]; then
  echo "No video files found in '$TARGET_DIR'."
  exit 0
fi

echo "Found ${#FILES[@]} file(s) to check."

for filename in "${FILES[@]}"; do
  printf '%s: checking %s... ' "$(date +%T)" "$filename"
  printf '%s:\n' "$filename" >> "$ERRORS_LOG"

  if ffmpeg -v error -nostats -i "$filename" -f null - >> "$ERRORS_LOG" 2>&1; then
    echo "PASSED" >> "$ERRORS_LOG"
    printf "${GREEN}PASSED${NC}\n"
    ((PASS++))
  else
    echo "FAILED" >> "$ERRORS_LOG"
    printf "${RED}FAILED${NC}\n"
    ((FAIL++))
  fi

  echo "---" >> "$ERRORS_LOG"
done

if [[ $FAIL -gt 0 ]]; then
  printf "Done. Passed: $PASS, ${RED}Failed: $FAIL${NC} (see video_errors.log for details)\n"
else
  echo "Done. Passed: $PASS, Failed: $FAIL"
fi
echo "Summary — Passed: $PASS, Failed: $FAIL" >> "$ERRORS_LOG"
