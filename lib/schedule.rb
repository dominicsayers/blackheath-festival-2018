# frozen_string_literal: true

require 'fileutils'
require_relative 'category'
require_relative 'group'

class Schedule
  attr_reader :category

  def matches
    @matches ||= matches_from_template
  end

  def pitches
    @pitches ||= pitches_from_list
  end

  private

  def initialize(subfolder, date_text)
    @category = Category.new(subfolder, date_text)
    @date_text = date_text

    template_file = "../festival-templates/schedules/#{category.template_name}.csv"
    @template = File.readlines(template_file)
  end

  def pitches_from_list
    result = front_matter_header('pitch_list') + front_matter_pitch_list + header + content('pitch_list')
    result.compact.flatten.join("\n")
  end

  def matches_from_template
    @group = nil
    result = front_matter_header('schedule') + front_matter_matches + header + content('schedule_groups')
    result.compact.flatten.join("\n")
  end

  def matches_from_text(line)
    if line == ''
      @group.finish
    elsif line.match?(/^Group/)
      @group = Group.new(category)
      @group.header(line)
    elsif line.match?(/^Time/)
      @group.add_pitches line
    elsif line.match?(/^00:/)
      @group.add_matches line
    end
  end

  def front_matter_header(style)
    [
      '---',
      "title: #{category.name}",
      "style: #{style}",
      'items:'
    ]
  end

  def front_matter_matches
    @template.map { |line| matches_from_text(line.strip) }
  end

  def front_matter_pitch_list
    category.pitches.map { |pitch| "  - #{pitch}" }
  end

  def header
    ['---']
  end

  def content(include_file)
    [
      '',
      "{% include #{include_file}.html %}"
    ]
  end
end
