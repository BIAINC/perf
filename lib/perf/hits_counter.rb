module Perf
  class HitsCounter
    def initialize(increments)
      @increments = increments
    end

    def start
      Configuration.storage.increment(@increments)
    end

    def stop
      # Do nothing.
    end

    def error
      # Do nothing.
    end
  end
end
