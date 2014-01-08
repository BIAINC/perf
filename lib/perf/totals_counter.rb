module Perf
  class TotalsCounter
    def initialize(increments)
      @increments = increments
    end

    def start
      # Do nothing
    end

    def stop
      Configuration.storage.increment(@increments)
    end

    def error
      # Do nothing
    end
  end
end
