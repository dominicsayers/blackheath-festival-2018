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
    front_matter = front_matter_hash('pitch_list').merge('items' => category.pitches)
    front_matter.to_yaml + content('pitch_list').join("\n")
  end

  def matches_from_template
    front_matter = front_matter_hash('match_schedule').merge('items' => front_matter_matches)
    front_matter.to_yaml + content('schedule_groups').join("\n")
  end

  def pitches_from_template
    front_matter_pitches.map do |pitch_key, pitch_data|
      pitch_name = pitch_data.delete(:pitch_name)
      sorted_data = pitch_data.sort_by { |k, _| k }.to_h
      front_matter = front_matter_hash('pitch_schedule', pitch_name).merge('items' => sorted_data)
      result = front_matter.to_yaml + content('schedule_pitch').join("\n")
      [pitch_key, result]
    end.to_h
  end

  def front_matter_matches
    @group = nil
    @groups = {}
    @template.each { |line| parse_text(line.strip, type: :match) }
    @groups
  end

  def front_matter_pitches
    @group = nil
    @pitches = {}
    @template.each { |line| parse_text(line.strip, type: :pitch) }
    @pitches
  end

  def parse_text(line, type:)
    if line == ''
      case type
      when :match
        add_group_matches
      when :pitch
        add_group_pitches
      end
    elsif line.match?(/^Group/)
      @group = Group.new(category)
      @group.name = line
    elsif line.match?(/^Time/)
      @group.add_pitches line
    elsif line.match?(/^00:/)
      @group.add_matches line
    end
  end

  def add_group_matches
    @groups.merge! @group.match_schedule
  end

  def add_group_pitches
    @group.pitch_schedule.each do |pitch_key, pitch_data|
      @pitches[pitch_key] ||= {}
      @pitches[pitch_key].merge! pitch_data
    end
  end

  def front_matter_hash(style, pitch_name = nil)
    title = category.name
    title += " #{pitch_name}" if pitch_name

    {
      'title' => title,
      'style' => style
    }
  end

  def content(include_file)
    [
      '---',
      '',
      "{% include #{include_file}.html %}"
    ]
  end
end
