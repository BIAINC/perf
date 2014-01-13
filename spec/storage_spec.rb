require 'spec_helper'
require 'redis'

describe Perf::Storage do
  context '::create_memory_storage' do
    it 'should create a memory storage' do
      Perf::Storage::MemoryStorage.should_receive(:new).and_call_original

      Perf::Storage.create_memory_storage.should be_a(Perf::Storage::MemoryStorage)
    end
  end

  context '::create_redis_storage' do
    let(:redis) { MockRedis.new }

    it 'should reject nil argument' do
      expect { Perf::Storage.create_redis_storage(nil) }.to raise_error(ArgumentError)
    end

    it 'should create redis storage' do
      Perf::Storage::RedisStorage.should_receive(:new).with(redis).and_call_original

      Perf::Storage.create_redis_storage(redis).should be_a(Perf::Storage::RedisStorage)
    end
  end

  context '::create' do
    context 'memory storage' do
      let(:settings) { {storage: 'memory'} }

      it 'should call ::create_memory_storage' do
        Perf::Storage.should_receive(:create_memory_storage).and_call_original

        Perf::Storage.create(settings).should be_a(Perf::Storage::MemoryStorage)
      end
    end

    context 'redis storage' do
      let(:settings) { {storage: 'redis', redis: {host: 'localhost', port: 6379 }} }

      before(:each) do
        Redis.stub(:new).and_return(MockRedis.new)
      end

      it 'should instantiate redis' do
        Redis.should_receive(:new).with(settings[:redis]).and_return(MockRedis.new)

        Perf::Storage.create(settings)
      end

      it 'should call ::create_redis_storage' do
        Perf::Storage.should_receive(:create_redis_storage).and_call_original

        Perf::Storage.create(settings).should be_a(Perf::Storage::RedisStorage)
      end

      it 'should reject missing Redis section' do
        settings.delete(:redis)

        expect { Perf::Storage.create(settings) }.to raise_error(ArgumentError)
      end
    end

    context 'invalid input' do
      it 'should reject nil settings' do
        expect { Perf::Storage.create(nil) }.to raise_error(ArgumentError)
      end

      it 'should reject missing storage key' do
        expect { Perf::Storage.create({}) }.to raise_error(ArgumentError)
      end

      it 'should reject unknown storage type' do
        expect { Perf::Storage.create({type: 'whatever'}) }.to raise_error(ArgumentError)
      end
    end
  end

end
