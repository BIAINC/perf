module Perf
  module Storage
    # Redis-backed storage for counters.
    class RedisStorage
      PERSISTENT_COUNTERS_KEY = 'perf:persistent'       # A hash with all persistent counters
      VOLATILE_COUNTERS_SET = 'perf:volatile'           # All known volatile counters
      VOLATILE_KEYS_SET = 'perf:volatile_sets'          # All known volatile keys
      DEFAULT_VOLATILE_KEY_TTL = 30 * 60                # Number of seconds volatile keys live

      attr_reader(:redis)
      attr_writer(:volatile_key_ttl)

      def initialize(redis)
        @redis = redis
      end

      def volatile_key_ttl
        @volatile_key_ttl || DEFAULT_VOLATILE_KEY_TTL
      end

      def increment(deltas)
        with_redis(deltas.size) do |redis|
          deltas.each do |counter, delta|
            redis.hincrby(PERSISTENT_COUNTERS_KEY, counter, delta)
          end
        end
      end

      def increment_volatile(deltas)
        redis.multi do |redis|
          deltas.each do |counter, delta|
            redis.sadd(VOLATILE_COUNTERS_SET, counter)
            redis.sadd(VOLATILE_KEYS_SET, volatile_key)

            redis.hincrby(volatile_key, counter, delta)
          end

          redis.expire(volatile_key, volatile_key_ttl)
        end
      end

      def decrement_volatile(deltas)
        redis.multi do |redis|
          deltas.each do |counter, delta|
            redis.hincrby(volatile_key, counter, -delta)
          end
          redis.expire(volatile_key, volatile_key_ttl)
        end
      end

      def volatile_key
        @volatile_key ||= "perf:volatile:#{Socket.gethostname}:#{Process.pid}"
      end

      def all_counters
        counters = redis.hgetall(PERSISTENT_COUNTERS_KEY)
        counters.each{|k, v| counters[k] = v.to_i}

        containers = redis.smembers(VOLATILE_KEYS_SET)

        redis.smembers(VOLATILE_COUNTERS_SET).each do |counter|
          sum = 0

          containers.each do |container|
            sum += redis.hget(container, counter).to_i
          end

          counters[counter] = sum
        end

        counters
      end

      def reset
        redis.del(PERSISTENT_COUNTERS_KEY, VOLATILE_KEYS_SET, VOLATILE_COUNTERS_SET)
      end

      private

      def with_redis(instructions_count, &block)
        if (instructions_count > 1)
          redis.multi(&block)
        else
          block[redis]
        end
      end
    end
  end
end
