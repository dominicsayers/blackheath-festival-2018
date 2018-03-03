# frozen_string_literal: true

require 'fileutils'

class Category
  attr_reader :name, :pitches, :times, :teams, :template_name

  def to_s
    @to_s ||= "category: #{name}\tteams: #{template_name}\tpitches: #{pitches.length}\t(#{@subfolder})"
  end

  private

  def initialize(subfolder, date_text)
    @subfolder = subfolder
    @name = subfolder.split('/')[1]
    @pitches = list_of 'pitches'
    @times = list_of('times').map { |time| "#{date_text} #{time}" }
    @teams = list_of 'teams'
    @template_name = teams.length
  end

  def list_of(type)
    File.read("#{@subfolder}#{type}.txt").split("\n")
  end
end
