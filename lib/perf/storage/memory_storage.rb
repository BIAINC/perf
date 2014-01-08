module Perf
  module Storage
    # In-memory storage for perf counters. Great for a single-process systems.
    class MemoryStorage
      def initialize(counters = {})
        @counters = counters
        @counters.default = 0
      end

      def increment(deltas)
        deltas.each do |counter, delta|
          @counters[counter] += delta
        end
      end

      def increment_volatile(deltas)
        increment(deltas)
      end

      def decrement_volatile(deltas)
        deltas.each do |counter, delta|
          @counters[counter] -= delta
        end
      end

      def all_counters
        @counters.dup.freeze
      end

      def reset
        @counters.clear
      end
    end
  end
end
