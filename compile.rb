#!/usr/bin/env ruby
# frozen_string_literal: true

# threads = (7..11).map { |age_group| Thread.new { Tournament.new(filename: "U#{age_group}.yml").schedule } }
# threads.each(&:join)

require 'pathname'
require_relative 'lib/schedule'

Dir.glob('categories/*/').each do |subfolder|
  pagename = Pathname.new('festival2018', schedule.category.name.downcase, 'schedule.md')
  puts pagename.basename

  schedule = Schedule.new(subfolder)
  puts schedule.category
  puts schedule

  File.open(pagename, 'wb') { |file| file.puts schedule }
  File.open(File.join('..', 'blackheathfc.github.io', pagename), 'wb') { |file| file.puts schedule }
end
