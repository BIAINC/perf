require 'spec_helper'
require './lib/perf/storage/redis_storage.rb'
require 'redis'

describe Perf::Storage::RedisStorage do
  let(:type) { Perf::Storage::RedisStorage }
  let(:redis) { mock_redis }
  let(:storage) { type.new(redis) }

  def mock_redis
    Redis.new.tap{|r|
      r.flushdb
    }
  end

  def expect_synchronize
    described_class.mutex.should_receive(:synchronize)
  end

  context 'storage' do
    subject { type.instance_methods }

    it { should include(:increment) }
    it { should include(:increment_volatile) }
    it { should include(:decrement_volatile) }
    it { should include(:volatile_key) }
    it { should include(:volatile_key_ttl)}

    it 'should not be thread-safe by default' do
      (!!storage.thread_safe).should eq false
    end
  end

  context '#increment' do
    it 'should register the counter' do
      redis.should_receive(:hincrby).with(type::PERSISTENT_COUNTERS_KEY, :counter, 123)

      storage.increment(counter: 123)
    end

    it 'should not use multi for a single operation' do
      redis.should_not_receive(:multi)

      storage.increment(counter: 123)
    end

    it 'should update multiple counters at once' do
      redis.should_receive(:multi).ordered.and_yield(redis)
      redis.should_receive(:hincrby).ordered.with(type::PERSISTENT_COUNTERS_KEY, :counter1, 1)
      redis.should_receive(:hincrby).ordered.with(type::PERSISTENT_COUNTERS_KEY, :counter2, 2)

      storage.increment(counter1: 1, counter2: 2)
    end

    context 'thread safe' do
      before(:each) do
        storage.stub(:thread_safe).and_return(true)
      end

      it 'should acquire exclusive access' do
        expect_synchronize
        storage.increment(counter1: 1, counter2: 2)
      end
    end
  end

  context '#increment_volatile' do
    it 'should register counter and key in redis' do
      redis.should_receive(:sadd).with(type::VOLATILE_COUNTERS_SET, :counter)
      redis.should_receive(:sadd).with(type::VOLATILE_KEYS_SET, storage.volatile_key)

      storage.increment_volatile(counter: 123)
    end

    it 'should set a counter' do
      redis.should_receive(:hincrby).with(storage.volatile_key, :counter, 123)

      storage.increment_volatile(counter: 123)
    end

    it 'should set multiple counters' do
      redis.should_receive(:hincrby).ordered.with(storage.volatile_key, :counter1, 1)
      redis.should_receive(:hincrby).ordered.with(storage.volatile_key, :counter2, 2)

      storage.increment_volatile(counter1: 1, counter2: 2)
    end

    it 'should extend key\'s lifetime' do
      redis.should_receive(:expire).with(storage.volatile_key, storage.volatile_key_ttl)

      storage.increment_volatile(counter: 123)
    end

    it 'should execute all commands within a single multi call' do
      redis.should_receive(:multi).ordered.and_yield(redis)
      redis.should_receive(:sadd).ordered
      redis.should_receive(:sadd).ordered
      redis.should_receive(:hincrby).ordered
      redis.should_receive(:expire).ordered

      storage.increment_volatile(counter: 123)
    end

    context 'thread safe' do
      before(:each) do
        storage.stub(:thread_safe).and_return(true)
      end

      it 'should acquire exclusive access' do
        expect_synchronize

        storage.increment_volatile(counter: 123)
      end
    end
  end

  context '#decrement_volatile' do
    before(:each) do
      storage.increment_volatile(counter: 123)
    end

    it 'should decrement redis value' do
      redis.should_receive(:hincrby).with(storage.volatile_key, :counter, -123)

      storage.decrement_volatile(counter: 123)
    end

    it 'should extend key\'s TTL' do
      redis.should_receive(:expire).with(storage.volatile_key, storage.volatile_key_ttl)

      storage.decrement_volatile(counter: 123)
    end

    it 'should update redis in a single call' do
      redis.should_receive(:multi).ordered.and_yield(redis)
      redis.should_receive(:expire).ordered
      redis.should_receive(:hincrby).ordered

      storage.decrement_volatile(counter: 123)
    end

    it 'should not delete the key' do
      redis.should_not_receive(:del)

      storage.decrement_volatile(counter: 123)
    end

    it 'deletes the key' do
      redis.del(storage.volatile_key)
      redis.should_receive(:del).once

      storage.decrement_volatile(counter: 123)
    end

    context 'thread safe' do
      before(:each) do
        storage.stub(:thread_safe).and_return(true)
      end

      it 'should acquire exclusive access' do
        expect_synchronize

        storage.decrement_volatile(counter: 123)
      end
    end
  end

  context '#volatile_key' do
    subject{storage.volatile_key}

    it {should_not be_nil}
    it {should_not be_empty}
  end

  context '#volatile_key_ttl' do
    it 'should have a default value' do
      storage.volatile_key_ttl.should eql(Perf::Storage::RedisStorage::DEFAULT_VOLATILE_KEY_TTL)
    end

    it 'should accept numbers' do
      3.times do
        ttl = rand(1..100)
        storage.volatile_key_ttl = ttl

        storage.volatile_key_ttl.should eql(ttl)
      end
    end

    it 'should restore default value' do
      storage.volatile_key_ttl = 100
      storage.volatile_key_ttl = nil
      storage.volatile_key_ttl.should eql(Perf::Storage::RedisStorage::DEFAULT_VOLATILE_KEY_TTL)
    end
  end

  context '#all_counters' do
    let(:all_counters) { storage.all_counters }
    subject { all_counters }

    it { should be_a(Hash) }
    it { should be_empty }

    it 'should include regular counters' do
      storage.increment(counter1: 1, counter2: 2)

      all_counters.should eql('counter1' => 1, 'counter2' => 2)
    end

    it 'should include volatile counters from current process' do
      storage.increment_volatile(counter1: 1, counter2: 2)

      all_counters.should eql('counter1' => 1, 'counter2' => 2)
    end

    it 'should combine with volatile counters from other sources' do
      other_storage = Perf::Storage::RedisStorage.new(redis)
      other_storage.stub(:volatile_key).and_return(UUID.generate.to_s)

      other_storage.increment_volatile(counter1: 1, counter2: 2)

      storage.increment_volatile(counter2: 2, counter3: 3)

      all_counters.should eql('counter1' => 1, 'counter2' => 4, 'counter3' => 3)
    end
  end

  context '#reset' do
    it 'should delete keys from redis' do
      redis.should_receive(:del).exactly(1).times

      storage.reset
    end

    it 'should delete all redis data' do
      redis.stub(:del) do |*args|
        [type::PERSISTENT_COUNTERS_KEY, type::VOLATILE_KEYS_SET, type::VOLATILE_COUNTERS_SET].sort.should eql(args.sort)
      end

      storage.reset
    end
  end
end
