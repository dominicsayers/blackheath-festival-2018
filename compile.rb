# frozen_string_literal: true

# threads = (7..11).map { |age_group| Thread.new { Tournament.new(filename: "U#{age_group}.yml").schedule } }
# threads.each(&:join)

require_relative 'lib/schedule'

Dir.glob('categories/*/').each do |subfolder|
  schedule = Schedule.new(subfolder)
  puts schedule.category
  puts schedule

  File.open("festival/#{schedule.category.name}.md", "wb") { |file| file.puts schedule }
  File.open("../blackheathfc.github.io/festival/#{schedule.category.name}.md", "wb") { |file| file.puts schedule }
end
