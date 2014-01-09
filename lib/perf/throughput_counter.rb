module Perf
  class ThroughputCounter
    def initialize(increments)
      @increments = increments
    end

    def start
      @start_time = Time.now
    end

    def stop
      duration = (Time.now - @start_time).round
      increments = {}
      @increments.each do |c, v|
        increments["#{c}.duration"] = duration
        increments["#{c}.volume"] = v
      end
      Perf::Configuration.storage.increment(increments)
    end

    def error
      # Do nothing
    end
  end
end
