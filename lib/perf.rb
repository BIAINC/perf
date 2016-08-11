require "perf/version"
require "active_support/core_ext/hash"

require "perf/configuration"
require "perf/storage/memory_storage"
require "perf/storage/redis_storage"
require "perf/activity_counter"
require "perf/duration_counter"
require "perf/failures_counter"
require "perf/hits_counter"
require "perf/throughput_counter"
require "perf/totals_counter"
require "perf/data"


module Perf
  extend self

  # Collects data for the given counters.
  def collect(*counters)
    counters.each{|c| c.start}
    res = nil

    begin
      res = yield if block_given?
      counters.each{|c| c.stop}
    rescue
      counters.each{|c| c.error}
      raise
    end
    res
  end

  def activity(*counters)
    ActivityCounter.new(get_increments(counters))
  end

  def totals(*counters)
    TotalsCounter.new(get_increments(counters))
  end

  def hits(*counters)
    HitsCounter.new(get_increments(counters))
  end

  def failures(*counters)
    FailuresCounter.new(get_increments(counters))
  end

  def duration(counter)
    DurationCounter.new(counter)
  end

  def throughput(counters)
    ThroughputCounter.new(counters)
  end

  private

  def get_increments(counters)
    if (counters.last.is_a?(Hash))
      increments = counters.delete_at(-1)
    else
      increments = {}
    end
    counters.each {|c| increments[c] = 1}
    increments
  end
end
