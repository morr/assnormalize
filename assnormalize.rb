#!/usr/bin/ruby
# == Synopsis
#
# assnormalize: normalizes ass files in current directory for vlc player
#
require "pp"
$KCODE = "u"

dir = "."

# get files
Dir.foreach(dir) do |f|
  next if [".", ".."].include?(f) || !f.match(/\.ass$/)

  data = nil
  File.open(dir+'/'+f, 'r') {|file| data = file.readlines }

  header = []
  content = []
  dst = header
  events_passed = false
  data.each do |line|
    next if line.strip.empty? && dst == content
    dst << line
    events_passed = true if line.match(/^\[Events\]/)
    dst = content if line.match(/^Format:/) && events_passed
  end
  content.sort! do |line1, line2|
    time_match = line1.match(/(\d\d?):(\d\d):(\d\d)\.(\d\d)/)
    time1 = Time.at(time_match[1].to_i*60*60*100+time_match[2].to_i*60*100+time_match[2].to_i*100+time_match[3].to_i)

    time_match = line2.match(/(\d\d?):(\d\d):(\d\d)\.(\d\d)/)
    time2 = Time.at(time_match[1].to_i*60*60*100+time_match[2].to_i*60*100+time_match[2].to_i*100+time_match[3].to_i)

    time1 <=> time2
  end

  File.open(dir+'/'+f, 'w') do |file|
    file.write(header.join(""))
    file.write(content.join(""))
  end
  puts f+" normalized"
end
