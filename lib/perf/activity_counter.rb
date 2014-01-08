module Perf
  class ActivityCounter
    def initialize(increments)
      @increments = increments  
    end

    def start
      Configuration.storage.increment_volatile(@increments)
    end

    def stop
      Configuration.storage.decrement_volatile(@increments)
    end

    def error
      stop
    end
  end
end