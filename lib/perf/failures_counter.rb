module Perf
  class FailuresCounter
    def initialize(increments)
      @increments = increments
    end

    def start
      # Do nothing
    end

    def stop
      # Do nothing
    end

    def error
      Configuration.storage.increment(@increments)
    end
  end
end
