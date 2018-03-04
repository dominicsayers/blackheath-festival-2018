# frozen_string_literal: true

require 'pathname'
require 'active_support/inflector'
require 'schedule'

module Compiler
  extend self

  def run(remote: false)
    puts Dir.pwd # debug

    Dir.glob('categories/*/').each do |subfolder|
      schedule = Schedule.new subfolder, '2018-04-29'
      folder = Pathname.new File.join('festival2018', schedule.category.name.downcase)
      puts folder # debug
      puts schedule.category

      # Matches
      pagename = folder.join 'schedule.md'
      put_file pagename, schedule.matches
      remote_pagename = Pathname.new File.join('..', 'blackheathfc.github.io', pagename)
      put_file remote_pagename, schedule.matches if remote

      # Pitches
      pagename = folder.join 'pitches.md'
      put_file pagename, schedule.pitches
      remote_pagename = Pathname.new File.join('..', 'blackheathfc.github.io', pagename)
      put_file remote_pagename, schedule.pitches if remote
    end
  end

  private

  def put_file(pathname, text)
    FileUtils.mkdir_p pathname.dirname
    File.open(pathname, 'wb') { |file| file.puts text }
  end
end

# threads = (7..11).map { |age_group| Thread.new { Tournament.new(filename: "U#{age_group}.yml").schedule } }
# threads.each(&:join)
