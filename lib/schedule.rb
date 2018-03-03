# frozen_string_literal: true

require 'fileutils'
require_relative 'category'
require_relative 'group'

class Schedule
  attr_reader :category

  def to_s
    @to_s ||= process_template
  end

  private

  def initialize(subfolder)
    @category = Category.new(subfolder)

    template_file = "../festival-templates/schedules/#{category.template_name}.csv"
    @template = File.readlines(template_file)
  end

  def process_template
    @group = nil

    result = [
      '---',
      "title: #{category.name} schedule",
      '---',
      "# #{category.name} schedule",
      ''
    ] + @template.map { |line| process_text(line.strip) }

    result.compact.flatten.join("\n")
  end

  def process_text(line)
    if line == ''
      @group.finish
    elsif line.match?(/^Group/)
      @group = Group.new(category)
      ['---', '', "## #{line}", '']
    elsif line.match?(/^Time/)
      @group.add_pitches line
    elsif line.match?(/^00:/)
      @group.add_matches line
    end
  end
end
