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
    result = front_matter_header + front_matter_content + header + content
    result.compact.flatten.join("\n")
  end

  def process_text(line, type = :markdown)
    if line == ''
      @group.finish(type)
    elsif line.match?(/^Group/)
      @group = Group.new(category)
      @group.header(line, type)
    elsif line.match?(/^Time/)
      @group.add_pitches line
    elsif line.match?(/^00:/)
      @group.add_matches line
    end
  end

  def front_matter_header
    [
      '---',
      "title: #{category.name} schedule",
      'groups:'
    ]
  end

  def front_matter_content
    @template.map { |line| process_text(line.strip, :front_matter) }
  end

  def header
    [
      '---',
      "# #{category.name} schedule",
      ''
    ]
  end

  def content
    @template.map { |line| process_text(line.strip) }
  end
end
