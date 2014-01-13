require_relative "storage/memory_storage"
require_relative "storage/redis_storage"

module Perf
  module Storage
    def self.create(settings)
      raise(ArgumentError, 'Nil settings!') if settings.nil?

      case(settings[:storage].to_s)
        when 'memory'
          create_memory_storage
        when 'redis'
          raise(ArgumentError, "Settings hash is missing required :redis element") unless settings[:redis]
          create_redis_storage(Redis.new(settings[:redis]))
        else
          raise(ArgumentError, "Unsupported storage type: #{settings[:storage]}")
      end
    end

    def self.create_memory_storage
      MemoryStorage.new
    end

    def self.create_redis_storage(r)
      raise(ArgumentError, "No redis storage!") if r.nil?
      RedisStorage.new(r)
    end
  end
end

