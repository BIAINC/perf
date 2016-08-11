require 'spec_helper'
require './lib/perf/storage/redis_storage.rb'
require 'redis'

describe Perf::Storage::RedisStorage do
  let(:type) { Perf::Storage::RedisStorage }
  let(:redis) { mock_redis }
  let(:storage) { type.new(redis) }

  def mock_redis
    r = Redis.new
    r.flushdb
    r
  end

  describe 'interface' do
    subject { described_class.new(redis)}

    it { is_expected.to respond_to  :increment }
    it { is_expected.to respond_to :increment_volatile }
    it { is_expected.to respond_to :decrement_volatile }
    it { is_expected.to respond_to :volatile_key }
    it { is_expected.to respond_to :volatile_key_ttl}

    it 'is not be thread-safe by default' do
      expect(!!storage.thread_safe).to be false
    end
  end

  describe '#increment' do
    it 'registers the counter' do
      expect(redis).to receive(:hincrby).with(type::PERSISTENT_COUNTERS_KEY, :counter, 123)

      storage.increment(counter: 123)
    end

    it 'does not use multi for a single operation' do
      expect(redis).not_to receive(:multi)

      storage.increment(counter: 123)
    end

    it 'updates multiple counters at once' do
      expect(redis).to receive(:multi).ordered.and_yield(redis)
      expect(redis).to receive(:hincrby).ordered.with(type::PERSISTENT_COUNTERS_KEY, :counter1, 1)
      expect(redis).to receive(:hincrby).ordered.with(type::PERSISTENT_COUNTERS_KEY, :counter2, 2)

      storage.increment(counter1: 1, counter2: 2)
    end

    context 'when redis fails' do
      before(:each) do
        allow(Perf::Configuration).to receive(:logger).and_return(Logger.new(File::NULL))
        allow(redis).to receive(:hincrby).and_raise("Test")
      end

      it 'does not fail' do
        expect{storage.increment(counter1: 1, counter2: 2)}.not_to raise_error
      end

      it 'returns correct value' do
        expect(storage.increment(counter1: 1, counter2: 2)).to eq :failed
      end
    end


    context 'thread safe' do
      before(:each) do
        allow(storage).to receive(:thread_safe).and_return(true)
      end

      it 'acquires exclusive access' do
        expect(Thread).to receive(:exclusive).and_yield

        storage.increment(counter1: 1, counter2: 2)
      end
    end
  end

  describe '#increment_volatile' do
    it 'registers counter and key in redis' do
      expect(redis).to receive(:sadd).with(type::VOLATILE_COUNTERS_SET, :counter)
      expect(redis).to receive(:sadd).with(type::VOLATILE_KEYS_SET, storage.volatile_key)

      storage.increment_volatile(counter: 123)
    end

    it 'sets a counter' do
      expect(redis).to receive(:hincrby).with(storage.volatile_key, :counter, 123)

      storage.increment_volatile(counter: 123)
    end

    it 'sets multiple counters' do
      expect(redis).to receive(:hincrby).ordered.with(storage.volatile_key, :counter1, 1)
      expect(redis).to receive(:hincrby).ordered.with(storage.volatile_key, :counter2, 2)

      storage.increment_volatile(counter1: 1, counter2: 2)
    end

    it 'extends key\'s lifetime' do
      expect(redis).to receive(:expire).with(storage.volatile_key, storage.volatile_key_ttl)

      storage.increment_volatile(counter: 123)
    end

    it 'executes all commands within a single multi call' do
      expect(redis).to receive(:multi).ordered.and_yield(redis)
      expect(redis).to receive(:sadd).ordered
      expect(redis).to receive(:sadd).ordered
      expect(redis).to receive(:hincrby).ordered
      expect(redis).to receive(:expire).ordered

      storage.increment_volatile(counter: 123)
    end

    context 'thread safe' do
      before(:each) do
        allow(storage).to receive(:thread_safe).and_return(true)
      end

      it 'acquires exclusive access' do
        expect(Thread).to receive(:exclusive).and_yield

        storage.increment_volatile(counter: 123)
      end
    end
  end

  describe '#decrement_volatile' do
    before(:each) do
      storage.increment_volatile(counter: 123)
    end

    it 'decrements redis value' do
      expect(redis).to receive(:hincrby).with(storage.volatile_key, :counter, -123)

      storage.decrement_volatile(counter: 123)
    end

    it 'extends key\'s TTL' do
      expect(redis).to receive(:expire).with(storage.volatile_key, storage.volatile_key_ttl)

      storage.decrement_volatile(counter: 123)
    end

    it 'updates redis in a single call' do
      expect(redis).to receive(:multi).ordered.and_yield(redis)
      expect(redis).to receive(:expire).ordered
      expect(redis).to receive(:hincrby).ordered

      storage.decrement_volatile(counter: 123)
    end

    it 'does not delete the key' do
      expect(redis).not_to receive(:del)

      storage.decrement_volatile(counter: 123)
    end

    it 'deletes the key' do
      redis.del(storage.volatile_key)
      expect(redis).to receive(:del).once

      storage.decrement_volatile(counter: 123)
    end

    context 'thread safe' do
      before(:each) do
        allow(storage).to receive(:thread_safe).and_return(true)
      end

      it 'acquires exclusive access' do
        expect(Thread).to receive(:exclusive).and_yield

        storage.decrement_volatile(counter: 123)
      end
    end
  end

  describe '#volatile_key' do
    subject{storage.volatile_key}

    it {is_expected.not_to be_nil}
    it {is_expected.not_to be_empty}
  end

  describe '#volatile_key_ttl' do
    it 'has a default value' do
      expect(storage.volatile_key_ttl).to eq Perf::Storage::RedisStorage::DEFAULT_VOLATILE_KEY_TTL
    end

    it 'accepts numbers' do
      3.times do
        ttl = rand(1..100)
        storage.volatile_key_ttl = ttl

        expect(storage.volatile_key_ttl).to eq ttl
      end
    end

    it 'restores default value' do
      storage.volatile_key_ttl = 100
      storage.volatile_key_ttl = nil
      expect(storage.volatile_key_ttl).to eq Perf::Storage::RedisStorage::DEFAULT_VOLATILE_KEY_TTL
    end
  end

  describe '#all_counters' do
    let(:all_counters) { storage.all_counters }
    subject { all_counters }

    it { is_expected.to be_a(Hash) }
    it { is_expected.to be_empty }

    it 'includes regular counters' do
      storage.increment(counter1: 1, counter2: 2)

      expect(all_counters).to eq ({'counter1' => 1, 'counter2' => 2})
    end

    it 'includes volatile counters from current process' do
      storage.increment_volatile(counter1: 1, counter2: 2)

      expect(all_counters).to eq ({'counter1' => 1, 'counter2' => 2})
    end

    it 'combine swith volatile counters from other sources' do
      other_storage = Perf::Storage::RedisStorage.new(redis)
      allow(other_storage).to receive(:volatile_key).and_return(SecureRandom.uuid)

      other_storage.increment_volatile(counter1: 1, counter2: 2)

      storage.increment_volatile(counter2: 2, counter3: 3)

      expect(all_counters).to eql('counter1' => 1, 'counter2' => 4, 'counter3' => 3)
    end
  end

  describe '#reset' do
    it 'should delete keys from redis' do
      allow(redis).to receive(:del).once

      storage.reset
    end

    it 'deletes all redis data' do
      allow(redis).to receive(:del) do |*args|
        expect([type::PERSISTENT_COUNTERS_KEY, type::VOLATILE_KEYS_SET, type::VOLATILE_COUNTERS_SET].sort).to eq args.sort
      end

      storage.reset
    end
  end
end
