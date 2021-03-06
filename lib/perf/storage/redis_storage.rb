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
      attr_accessor(:thread_safe)

      def initialize(redis)
        @redis = redis
      end

      def volatile_key_ttl
        @volatile_key_ttl || DEFAULT_VOLATILE_KEY_TTL
      end

      def increment(deltas)
        with_redis(deltas.size > 1) do |redis|
          deltas.each do |counter, delta|
            redis.hincrby(PERSISTENT_COUNTERS_KEY, counter, delta)
          end
        end
      end

      def increment_volatile(deltas)
        with_redis(true) do |redis|
          deltas.each do |counter, delta|
            redis.sadd(VOLATILE_COUNTERS_SET, counter)
            redis.sadd(VOLATILE_KEYS_SET, volatile_key)

            redis.hincrby(volatile_key, counter, delta)
          end

          redis.expire(volatile_key, volatile_key_ttl)
        end
      end

      def decrement_volatile(deltas)
        with_lock do
          results = redis.multi do |redis|
            redis.expire(volatile_key, volatile_key_ttl)
            deltas.each do |counter, delta|
              redis.hincrby(volatile_key, counter, -delta)
            end
          end

          unless (results.first)
            # The key was not there; get rid of it
            redis.del(volatile_key)
          end
        end
      end

      def volatile_key
        @volatile_key ||= "perf:volatile:#{Socket.gethostname}:#{Process.pid}"
      end

      def all_counters
        # No need to lock here - the method may return inconsistent data anyway.
        persistent_data, volatile_counters, volatile_sets = redis.multi do |redis|
          redis.hgetall(PERSISTENT_COUNTERS_KEY)
          redis.smembers(VOLATILE_COUNTERS_SET)
          redis.smembers(VOLATILE_KEYS_SET)
        end

        all_volatile_data = redis.multi do |redis|
          volatile_sets.each{|s| redis.hgetall(s) }
        end

        volatile_data = volatile_counters.inject({}){|h, c| h[c] = all_volatile_data.inject(0){|v, s| v += s[c].to_i}; h}

        counters = persistent_data.inject({}){|h, (c, v)| h[c] = v.to_i; h}
        counters.merge(volatile_data).with_indifferent_access.tap{|h| h.default = 0}
      end

      def reset
        redis.del(PERSISTENT_COUNTERS_KEY, VOLATILE_KEYS_SET, VOLATILE_COUNTERS_SET)
      end

      private

      def with_redis(transactional, &block)
        with_lock do
          if (transactional)
            redis.multi(&block)
          else
            block[redis]
          end
        end
      rescue => ex
        Configuration.logger.error("Perf redis failure: #{ex}")
        :failed
      end

      def with_lock(&block)
        if (thread_safe)
          Thread.exclusive(&block)
        else
          block.call
        end
      end
    end
  end
end
