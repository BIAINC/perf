module Perf
  class DurationCounter
    def initialize(name)
      @name = name
    end

    def start
      @start_time = Time.now
    end

    def stop
      ms = ((Time.now - @start_time) * 1000).round
      Configuration.storage.increment(@name => ms)
    end

    def error
      # Do nothing.
    end
  end
end
