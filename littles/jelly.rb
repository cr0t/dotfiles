#!/usr/bin/env ruby
# frozen_string_literal: true

# Rename episode files into Jellyfin-friendly "SxxExx" scheme.
#
# Usage:
#   ruby rename_episodes.rb --season 1 [--prefix "Три кота"] [--path .] [--force] [--dry-run]
#   ruby rename_episodes.rb --season 2 --offset 52 --path ./season2
#
# Options:
#   --path, -p     Directory containing episode files (default: current directory)
#   --season, -s   Season number (required)
#   --offset, -o   Subtract this number from each detected episode number before
#                  formatting as ExX. Use this when files are numbered with an
#                  absolute/continuous counter across seasons (e.g. Season 2 files
#                  are numbered 53-104) and you want them reset to E01-E52.
#                  Pass the number of episodes in all PRECEDING seasons combined
#                  (e.g. --offset 52 turns absolute #53 into E01).
#   --prefix       Show name prefix to prepend (optional)
#   --force        Actually rename anomalous/good files without prompting again after warnings
#   --dry-run      Show planned renames without touching any files
#   --ext          Comma-separated list of extensions to consider (default: mp4,mkv,avi,mov)
#
# Behavior:
#   1. Scans all matching files in --path (non-recursive).
#   2. Extracts an episode number from each filename (leading number, or any
#      standalone number token if no leading number is found).
#   3. Applies --offset (if given) by subtracting it from the detected number.
#   4. If every file yields a unique, unambiguous, POSITIVE post-offset episode
#      number -> renames all.
#   5. If some files are ambiguous/have no number/duplicate numbers/would go
#      non-positive after offset -> renames only the confidently-resolved files
#      (unless --dry-run), shows examples, and lists the rest for manual
#      handling. Nothing destructive happens to files it isn't sure about.

require 'optparse'
require 'pathname'

options = {
  path: '.',
  season: nil,
  offset: 0,
  prefix: nil,
  force: false,
  dry_run: false,
  ext: %w[mp4 mkv avi mov]
}

OptionParser.new do |opts|
  opts.banner = 'Usage: ruby rename_episodes.rb --season N [options]'

  opts.on('-p', '--path PATH', 'Directory with episode files (default: .)') { |v| options[:path] = v }
  opts.on('-s', '--season N', Integer, 'Season number (required)') { |v| options[:season] = v }
  opts.on('-o', '--offset N', Integer,
          'Subtract N from each detected episode number (for absolute numbering reset)') do |v|
    options[:offset] = v
  end
  opts.on('--prefix NAME', 'Show name prefix, e.g. "Три кота"') { |v| options[:prefix] = v }
  opts.on('--force', 'Rename resolvable files even if some anomalies exist') { options[:force] = true }
  opts.on('--dry-run', 'Only print what would happen, do not rename anything') { options[:dry_run] = true }
  opts.on('--ext LIST', 'Comma-separated extensions (default: mp4,mkv,avi,mov)') do |v|
    options[:ext] = v.split(',').map { |e| e.strip.sub(/^\./, '').downcase }
  end
  opts.on('-h', '--help', 'Show this help') do
    puts opts
    exit
  end
end.parse!

if options[:season].nil?
  warn 'Error: --season is required.'
  exit 1
end

dir = Pathname.new(options[:path])
unless dir.directory?
  warn "Error: path '#{dir}' is not a directory."
  exit 1
end

season = options[:season]
offset = options[:offset]
prefix = options[:prefix]&.strip
exts = options[:ext]

files = dir.children.select do |f|
  f.file? && exts.include?(f.extname.delete_prefix('.').downcase)
end.sort_by { |f| f.basename.to_s }

if files.empty?
  warn "No files with extensions [#{exts.join(', ')}] found in #{dir}."
  exit 1
end

# --- Episode number extraction -------------------------------------------
#
# Strategy, in order of preference (first match wins):
#   1. Leading number at the very start of the filename: "01. Title.mp4", "12 - Title.mkv",
#      "000 - Title.mkv". Supports any number of digits and an optional "-N" part-suffix
#      (e.g. "033-2" -> treated as episode 33, part 2 folded into the title).
#   2. A number token that appears anywhere before the first " - " separator, when the
#      filename doesn't start with the number but still has a clear "NUMBER - Title" shape
#      (e.g. "Малышарики 000 - Знакомство.mkv").
#   3. Existing SxxExx pattern already in the name (extract E number).
#   4. Any standalone number token surrounded by non-digits, ONLY if exactly one such
#      token exists in the whole filename (low-confidence fallback).
#
# Numbers can be any length (not capped at 2-3 digits) so seasons with 100+ episodes work.
#
# Returns: { number: Integer, confidence: :high/:medium, rest_title: String } or nil

def extract_episode_info(basename_no_ext)
  # 1. Leading number, optionally with a "-N" part suffix: "01. Foo", "12 - Foo",
  #    "000 - Foo", "033-2 - Foo"
  if (m = basename_no_ext.match(/\A0*(\d+)(?:-(\d+))?[.\-_\s]+(.*)\z/))
    num = m[1].to_i
    part = m[2]
    rest = m[3].strip
    rest = "Part #{part} - #{rest}" if part
    return { number: num, confidence: :high, rest_title: rest }
  end

  # 2. Number appears before the first " - " separator but isn't at position 0
  #    (e.g. a show-name prefix precedes it): "Малышарики 000 - Знакомство"
  if basename_no_ext.include?(' - ')
    head, rest = basename_no_ext.split(' - ', 2)
    if (m = head.match(/\A(.*?)\b0*(\d+)(?:-(\d+))?\s*\z/))
      num = m[2].to_i
      part = m[3]
      rest_title = rest.strip
      rest_title = "Part #{part} - #{rest_title}" if part
      return { number: num, confidence: :high, rest_title: rest_title }
    end
  end

  # 3. Existing SxxExx pattern
  if (m = basename_no_ext.match(/[Ss]\d{1,2}[Ee](\d+)/))
    rest = basename_no_ext.sub(m[0], '').strip.sub(/\A[.\-_\s]+/, '')
    return { number: m[1].to_i, confidence: :high, rest_title: rest }
  end

  # 4. Fallback: exactly one standalone number token anywhere in the filename
  candidates = basename_no_ext.scan(/(?<!\d)(\d+)(?!\d)/)
  if candidates.size == 1
    num_str = candidates.first.first
    num = num_str.to_i
    rest = basename_no_ext.sub(num_str, '').strip.sub(/\A[.\-_\s]+/, '')
    return { number: num, confidence: :medium, rest_title: rest }
  end

  nil # no confident number found
end

# --- Build rename plan ------------------------------------------------------

Result = Struct.new(:file, :info, :adjusted_number, :new_name)

resolved = []
unresolved = []

files.each do |f|
  ext = f.extname
  base = f.basename(ext).to_s
  info = extract_episode_info(base)

  if info.nil?
    unresolved << { file: f, reason: 'no episode number found' }
    next
  end

  adjusted = info[:number] - offset
  if adjusted < 1
    unresolved << {
      file: f,
      reason: "offset would produce non-positive episode number " \
              "(detected #{info[:number]} - offset #{offset} = #{adjusted})"
    }
    next
  end

  resolved << Result.new(f, info, adjusted, nil)
end

# Detect duplicate POST-OFFSET episode numbers among resolved files -> demote to unresolved
by_number = resolved.group_by(&:adjusted_number)
duplicates = by_number.select { |_, group| group.size > 1 }

duplicates.each do |num, group|
  group.each do |r|
    resolved.delete(r)
    unresolved << { file: r.file, reason: "duplicate resulting episode number #{num} shared with #{group.size - 1} other file(s)" }
  end
end

# Build final filenames for resolved entries
resolved.each do |r|
  ext = r.file.extname
  ep_str = format('S%02dE%02d', season, r.adjusted_number)
  title_part = r.info[:rest_title].to_s.strip
  title_part = title_part.sub(/\A[-_.]+/, '').strip

  name_parts = []
  name_parts << prefix if prefix && !prefix.empty?
  name_parts << ep_str
  base_name = name_parts.join(' ')
  base_name += " - #{title_part}" unless title_part.empty?

  # Safety net: collapse any accidental double spaces / stray separators
  base_name = base_name.gsub(/\s+/, ' ').gsub(/\s*-\s*-\s*/, ' - ').strip

  r.new_name = "#{base_name}#{ext}"
end

# --- Report ------------------------------------------------------------

puts "Scanned #{files.size} file(s) in #{dir}"
puts "Season: #{season}" + (offset.positive? ? ", Offset: -#{offset}" : '') + (prefix ? ", Prefix: \"#{prefix}\"" : '')
puts

if unresolved.empty?
  puts "All #{resolved.size} file(s) resolved cleanly. Planned renames:"
else
  puts "#{resolved.size} file(s) resolved, #{unresolved.size} file(s) NEED MANUAL ATTENTION:"
  unresolved.each do |u|
    puts "  ! #{u[:file].basename} -- #{u[:reason]}"
  end
  puts
  puts 'Example renames for the files that WILL be processed:'
end

sample = resolved.first(5)
sample.each do |r|
  detected = r.info[:number]
  suffix = offset.positive? ? " (detected ##{detected}, offset -#{offset})" : ''
  puts "  #{r.file.basename}  ->  #{r.new_name}#{suffix}"
end
puts "  ... and #{resolved.size - sample.size} more" if resolved.size > sample.size
puts

# --- Collision check among planned new names --------------------------

new_names = resolved.map(&:new_name)
name_collisions = new_names.group_by { |n| n }.select { |_, v| v.size > 1 }.keys
if name_collisions.any?
  warn "Aborting: planned renames collide on: #{name_collisions.join(', ')}"
  warn 'Fix source filenames/season number/offset and re-run.'
  exit 1
end

# Also make sure we're not clobbering an existing different file
resolved.each do |r|
  target = r.file.dirname + r.new_name
  if target.exist? && target != r.file
    warn "Aborting: target already exists and would be overwritten: #{r.new_name}"
    exit 1
  end
end

if options[:dry_run]
  puts '(dry run - no files were renamed)'
  exit 0
end

if resolved.empty?
  puts 'Nothing to rename.'
  exit 0
end

if unresolved.any? && !options[:force]
  print "Some files are unresolved. Proceed renaming the #{resolved.size} resolvable file(s) now? [y/N] "
  answer = $stdin.gets&.strip&.downcase
  unless answer == 'y'
    puts 'Aborted. No files were renamed.'
    exit 0
  end
end

resolved.each do |r|
  target = r.file.dirname + r.new_name
  File.rename(r.file, target)
  puts "Renamed: #{r.file.basename} -> #{r.new_name}"
end

puts
puts "Done. #{resolved.size} file(s) renamed."
if unresolved.any?
  puts "#{unresolved.size} file(s) left untouched for manual review:"
  unresolved.each { |u| puts "  - #{u[:file].basename} (#{u[:reason]})" }
end
