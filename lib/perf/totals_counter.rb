require_relative 'hash_processor'

module Perf
  class TotalsCounter
    include HashProcessor

    def initialize(increments)
      @increments = increments
    end

    def start
      # Do nothing
    end

    def stop
      Configuration.storage.increment(process_hash(@increments))
    end

    def error
      # Do nothing
    end
  end
end
