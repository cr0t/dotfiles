#!/usr/bin/env ruby

# Runs `ps` and processes its output for more human readable format to check
# what processes consumes too much memory. Also, combines multiprocesses apps
# and calculates their total memory footprint.

# Uncomment this to clean up some RAM (you will need to input your sudo
# password every time you run this script).
#`sudo purge`

PRC_NAME_CROP_AT=160
TOP_COUNT = 20
MULTI_PROCESS_APPS = [
  'Google Chrome.app',
  'Slack.app',
  'Visual Studio Code.app',
  'Dropbox.app',
  'iTerm.app'
].freeze

memory_by_process = Hash.new(0)
processes = `ps aux`

m_bytes = processes.split("\n").reduce(0) { |memo, prc|
  fields    = prc.split(/\s+/)

  mem_bytes = fields[5].to_i
  prc_name  = fields[10...fields.length].join(' ')

  MULTI_PROCESS_APPS.each do |app_name|
    prc_name = app_name.gsub('.app', '') if prc_name.include? app_name
  end

  memory_by_process[prc_name] += mem_bytes

  memo + mem_bytes
}

mega_bytes = (m_bytes / 1024.0).round(2)
total_memory = `sysctl hw.memsize`.match(/\d+/)[0].to_i # hw.memsize: 17179869184
total_memory_in_megabytes = total_memory / 1024 / 1024
one_percent_from_total_memory = (total_memory_in_megabytes / 100.0)
used_percent = (mega_bytes / one_percent_from_total_memory).round(2)
puts "Total: #{mega_bytes}MB of #{total_memory_in_megabytes}MB of RAM is used by processes (#{used_percent}% is used)"

puts "TOP-#{TOP_COUNT}:"
top_n_bytes_sum = 0
memory_by_process.sort_by { |k, value| value }.reverse[0...TOP_COUNT].each { |mem|
  prc_name = mem[0][0...PRC_NAME_CROP_AT]
  prc_name += '...' if mem[0].length > PRC_NAME_CROP_AT
  m_bytes = mem[1] / 1024.0
  percent = sprintf('%.2f', (m_bytes / one_percent_from_total_memory))
  mega_bytes = sprintf('%.1f', m_bytes)
  puts "#{mega_bytes} #{percent}%\t#{prc_name}"
  top_n_bytes_sum += mem[1]
}
mega_bytes = top_n_bytes_sum / 1024
puts "TOP-#{TOP_COUNT} apps use #{mega_bytes}MBs of RAM, total number of processes is #{memory_by_process.count}"
puts "uptime: #{`uptime`}"
