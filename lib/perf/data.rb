module Perf
  module Data
    def self.get
      Configuration.storage.all_counters
    end

    def self.reset
      Configuration.storage.reset
    end
  end
end
