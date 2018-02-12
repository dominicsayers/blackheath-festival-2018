# frozen_string_literal: true

require_relative '../tournament_schedule/lib/tournament'
# threads = (7..11).map { |age_group| Thread.new { Tournament.new(filename: "U#{age_group}.yml").schedule } }
# threads.each(&:join)
Tournament.new(filename: "U10.yml").schedule
