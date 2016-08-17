require 'logger'

module Perf
  module Configuration

    DEFAULT_ACTIVITY_TTL = 300
    extend self

    attr_writer(:storage)

    def storage
      @storage ||= Storage::MemoryStorage.new
    end

    attr_writer(:activity_ttl_seconds)

    def activity_ttl_seconds
      @activity_ttl_seconds ||= DEFAULT_ACTIVITY_TTL
    end

    attr_writer(:logger)

    def logger
      @logger ||= create_default_logger
    end

    private

    def create_default_logger
      logger = ::Logger.new(STDOUT)
      logger.level = ::Logger::INFO
      logger
    end
  end
end
