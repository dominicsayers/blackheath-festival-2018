# frozen_string_literal: true

class Group
  def add_pitches(line)
    elements = line.split(',')[1, 99]
    pitch_numbers = elements.map { |t| t.split(' ')[1].to_i }
    @pitches = pitch_numbers.map { |n| category.pitches[n - 1] }

    nil
  end

  def add_matches(line)
    elements = line.split(',')

    times << time_from(elements.shift)
    teams = [[], []]

    elements.each { |element| process_element(teams, element) }

    home << teams[0]
    away << teams[1]
    nil
  end

  def finish
    data = []

    pitches.each_with_index do |pitch, pitch_index|
      data << "### #{pitch}"
      data << ''

      times.each_with_index do |time, time_index|
        data << "| #{time} | #{home[time_index][pitch_index]} | v | #{away[time_index][pitch_index]} |"
      end

      data << ''
    end

    data
  end

  private

  attr_reader :category, :pitches, :times, :home, :away

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

  def time_from(text)
    time_index = text.split(':')[1].to_i
    category.times[time_index - 1]
  end

  def team_from(index)
    category.teams[index.to_i]
  end
end
