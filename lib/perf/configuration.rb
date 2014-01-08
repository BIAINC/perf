module Perf
  module Configuration

    DEFAULT_ACTIVITY_TTL = 300

    class << self
      attr_writer(:storage)

      def storage
        @storage ||= Storage::MemoryStorage.new
      end

      attr_writer(:activity_ttl_seconds)

      def activity_ttl_seconds
        @activity_ttl_seconds ||= DEFAULT_ACTIVITY_TTL
      end
    end
  end
end
