# frozen_string_literal: true

require 'active_support/inflector'

class Group
  attr_reader :pitches, :times
  attr_accessor :name

  def header(line)
    ["  #{line}:"]
  end

  def add_pitches(line)
    elements = line.split(',')[1, 99]
    pitch_numbers = elements.map { |t| t.split(' ')[1].to_i }
    @pitches = pitch_numbers.map { |n| category.pitches[n - 1] }

    nil
  end

  def add_matches(line)
    elements = line.split(',')

    times << elements.shift
    teams = [[], []]

    elements.each { |element| process_element(teams, element) }

    home << teams[0]
    away << teams[1]
    nil
  end

  def match_schedule
    data = { name => {} }

    pitches.each_with_index do |pitch, pitch_index|
      data[name][pitch] = []

      times.each_with_index do |time, time_index|
        data[name][pitch] << {
          'time' => time_from(time),
          'home' => home[time_index][pitch_index],
          'away' => away[time_index][pitch_index]
        }
      end
    end

    data
  end

  def pitch_schedule
    data = {}

    pitches.each_with_index do |pitch, pitch_index|
      times.each_with_index do |time, time_index|
        time_key = time_key_from(time)

        data[pitch.parameterize] ||= { pitch_name: pitch }
        data[pitch.parameterize][time_key] = {
          'time' => time_from_key(time_key),
          'group' => name,
          'home' => home[time_index][pitch_index],
          'away' => away[time_index][pitch_index]
        }
      end
    end

    data
  end

  private

  attr_reader :category, :home, :away

  INDENT = '        '

  def initialize(category)
    @category = category
    @times = []
    @home = []
    @away = []
  end

  def process_element(teams, element)
    ids = element.split(' v ')
    (0..1).each { |i| teams[i] << team_from(ids[i]) }
  end

  def time_key_from(text)
    time_index = text.split(':')[1].to_i
  end

  def time_from_key(time_key)
    category.times[time_key - 1]
  end

  def time_from(text)
    time_from_key time_key_from(text)
  end

  def team_from(index)
    category.teams[index.to_i]
  end
end
