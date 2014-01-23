require_relative 'hash_processor'

module Perf
  class FailuresCounter
    include HashProcessor

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
      Configuration.storage.increment(process_hash(@increments))
    end
  end
end
