# frozen_string_literal: true

require 'fileutils'
require 'yaml'
require 'category'
require 'group'

class Schedule
  attr_reader :category

  def matches
    @matches ||= matches_from_template
  end

  def pitches
    @pitches ||= pitches_from_template
  end

  def pitch_list
    @pitch_list ||= pitches_from_list
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
    front_matter = front_matter_hash('match_schedule').merge('items' => front_matter_matches)
    front_matter.to_yaml + (header + content('schedule_groups')).join("\n")
  end

  def front_matter_matches
    @group = nil
    @groups = {}
    @template.each { |line| matches_from_text(line.strip) }
    @groups
  end

  def matches_from_text(line)
    if line == ''
      @groups.merge! @group.match_schedule
    elsif line.match?(/^Group/)
      @group = Group.new(category)
      @group.name = line
    elsif line.match?(/^Time/)
      @group.add_pitches line
    elsif line.match?(/^00:/)
      @group.add_matches line
    end
  end

  def pitches_from_template
    front_matter_pitches.map do |pitch_key, pitch_data|
      pitch_name = pitch_data.delete(:pitch_name)
      sorted_data = pitch_data.sort_by { |k, _| k }.to_h
      front_matter = front_matter_hash('pitch_schedule', pitch_name).merge('items' => sorted_data)
      result = front_matter.to_yaml + (header + content('schedule_pitch')).join("\n")
      [pitch_key, result]
    end.to_h
  end

  def front_matter_pitches
    @group = nil
    @pitches = {}
    @template.each { |line| pitches_from_text(line.strip) }
    @pitches
  end

  def pitches_from_text(line)
    if line == ''
      add_group_pitches
    elsif line.match?(/^Group/)
      @group = Group.new(category)
      @group.name = line
    elsif line.match?(/^Time/)
      @group.add_pitches line
    elsif line.match?(/^00:/)
      @group.add_matches line
    end
  end

  def add_group_pitches
    @group.pitch_schedule.each do |pitch_key, pitch_data|
      @pitches[pitch_key] ||= {}
      @pitches[pitch_key].merge! pitch_data
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

  def front_matter_hash(style, pitch_name = nil)
    title = category.name
    title += " #{pitch_name}" if pitch_name

    {
      'title' => title,
      'style' => style
    }
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
