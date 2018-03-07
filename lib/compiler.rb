# frozen_string_literal: true

require 'compiler/category'

EVENT_DATE = '2018-04-29'

class Compiler
  def run
    Dir.glob('categories/*/').each do |subfolder|
      category_compiler = Compiler::Category.new(subfolder, remote: remote, date_text: EVENT_DATE)
      category_compiler.generate_matches
      category_compiler.generate_pitches
      category_compiler.generate_pitch_list
    end
  end

  private

  attr_reader :remote

  def initialize(remote: false)
    @remote = remote
  end
end

# threads = (7..11).map { |age_group| Thread.new { Tournament.new(filename: "U#{age_group}.yml").schedule } }
# threads.each(&:join)
