module Perf
  module Storage
    # In-memory storage for perf counters. Great for a single-process systems.
    class MemoryStorage
      def self.new_storage_hash
        Hash.new.with_indifferent_access.tap{|h| h.default = 0}
      end

      def initialize(counters = MemoryStorage.new_storage_hash)
        @counters = counters
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
        @counters.dup.tap{|h| h.default = 0}
      end

      def reset
        @counters.clear
      end
    end
  end
end
