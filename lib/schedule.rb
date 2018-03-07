# frozen_string_literal: true

require 'fileutils'
require 'yaml'
require 'category'
require 'group'

class Schedule
  attr_reader :category

  def matches
    @matches ||= content('match_schedule', front_matter_matches, 'schedule_groups')
  end

  def pitches
    @pitches ||= begin
      front_matter_pitches.map do |pitch_key, pitch_data|
        pitch_name = pitch_data.delete(:pitch_name)
        sorted_data = pitch_data.sort_by { |k, _| k }.to_h
        [pitch_key, content('pitch_schedule', sorted_data, 'schedule_pitch', pitch_name: pitch_name)]
      end.to_h
    end
  end

  def pitch_list
    @pitch_list ||= content('pitch_list', category.pitches, 'pitch_list')
  end

  private

  def initialize(subfolder, date_text)
    @category = Category.new(subfolder, date_text)
    @date_text = date_text

    template_file = "../festival-templates/schedules/#{category.template_name}.csv"
    @template = File.readlines(template_file)
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
      finish_group type
    elsif line.match?(/^Group/)
      @group = Group.new(category)
      @group.name = line
    elsif line.match?(/^Time/)
      @group.add_pitches line
    elsif line.match?(/^00:/)
      @group.add_matches line
    end
  end

  def finish_group(type)
    case type
    when :match
      add_group_matches
    when :pitch
      add_group_pitches
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

  def content(style, items, include_file, pitch_name: nil)
    title = category.name
    title += " #{pitch_name}" if pitch_name

    {
      'title' => title,
      'style' => style
    }.merge('items' => items).to_yaml + <<~CONTENT
      ---

      {% include #{include_file}.html %}
    CONTENT
  end
end
