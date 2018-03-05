# frozen_string_literal: true

require 'date'
require 'pathname'
require 'schedule'

class Compiler
  class Category
    def generate_matches
      generate_file 'schedule.md', schedule.matches
    end

    def generate_pitches
      schedule.pitches.each do |pitch_key, pitch_text|
        generate_file File.join('pitches', "#{pitch_key}.md"), pitch_text
      end
    end

    def generate_pitch_list
      generate_file 'pitches.md', schedule.pitch_list
    end

    private

    DEFAULT_OPTIONS = { remote: false, date_text: Date.today.to_s }.freeze

    def initialize(subfolder, configured_options = {})
      @subfolder = subfolder
      @options = DEFAULT_OPTIONS.merge configured_options
      puts folder # debug
      puts schedule.category
    end

    def schedule
      @schedule ||= Schedule.new @subfolder, @options[:date_text]
    end

    def folder
      @folder ||= Pathname.new File.join('festival2018', schedule.category.name.downcase)
    end

    def remote
      @remote ||= @options[:remote]
    end

    def generate_file(filename, text)
      pagename = folder.join filename
      write_file pagename, text

      return unless remote

      remote_pagename = Pathname.new File.join('..', 'blackheathfc.github.io', pagename)
      write_file remote_pagename, text if remote
    end

    def write_file(pathname, text)
      FileUtils.mkdir_p pathname.dirname
      File.open(pathname, 'wb') { |file| file.puts text }
    end
  end
end
