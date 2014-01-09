module Perf
  class DurationCounter
    def initialize(name)
      @name = name
    end

    def start
      @start_time = Time.now
    end

    def stop
      seconds = (Time.now - @start_time).round
      Configuration.storage.increment(@name => seconds)
    end

    def error
      # Do nothing.
    end
  end
end
