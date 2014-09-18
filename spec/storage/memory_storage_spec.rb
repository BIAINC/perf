require 'spec_helper'
require './lib/perf/storage/memory_storage'

describe Perf::Storage::MemoryStorage do
  let(:type) { Perf::Storage::MemoryStorage }
  let(:counters) { Perf::Storage::MemoryStorage.new_storage_hash }
  let(:storage) { type.new(counters) }

  context 'instance methods' do
    subject { type.instance_methods }

    it { should include(:increment) }
    it { should include(:increment_volatile) }
    it { should include(:decrement_volatile) } 
  end

  context '#increment' do
    before(:each) do
      counters.clear
    end

    context 'new counters' do
      it 'should increment' do
        storage.increment(foo: 1, bar: 5)

        counters.should eql("foo" => 1, "bar" => 5)
      end
    end

    context 'existing counters' do
      before(:each) do
        counters[:foo] =  1
        counters[:bar] = 2
      end

      it 'should increment' do
        storage.increment(foo: 3, bar: 5)

        counters.should eql("foo" => 4, "bar" => 7)
      end
    end
  end

  context '#increment_volatile' do
    it 'should call increment' do
      storage.should_receive(:increment).with(foo: 1, bar: 25)

      storage.increment_volatile({foo: 1, bar: 25})
    end

    it 'should set new and existing counters' do
      counters[:existing] = 5

      storage.increment_volatile(existing: 10, new: 25)

      counters.should eql("existing" => 15, "new" => 25)
    end
  end

  context '#decrement_volatile' do
    it 'should decrement exising counters' do
      counters[:existing1] = 10
      counters[:existing2] = 15
      counters[:existing3] = 20

      storage.decrement_volatile(existing1: 2, existing2: 3)

      counters.should eql("existing1" => 8, "existing2" => 12, "existing3" => 20)
    end
  end

  context '#all_counters' do
    let(:all_counters) { storage.all_counters }
    subject { all_counters }

    it { should be_kind_of(Hash) }
    it { should be_empty }


    it 'should include regular counters' do
      storage.increment(foo: 1, bar: 2)

      all_counters.should eql("foo" => 1, "bar" => 2)
    end

    it 'should include volatile counters' do
      storage.increment_volatile(foo: 1, bar: 2)

      all_counters.should eql("foo" => 1, "bar" => 2)
    end
  end

  context '#reset' do
    let(:all_counters) { storage.all_counters }

    it 'should not fail on an empty set' do
      expect { storage.reset }.not_to raise_error
    end

    it 'should reset regular counters' do
      storage.increment(foo: 1, bar: 2)
      storage.reset
      all_counters.should be_empty
    end

    it 'should reset volatile counters' do
      storage.increment_volatile(foo: 1, bar: 2)
      storage.reset
      all_counters.should be_empty
    end
  end
end
