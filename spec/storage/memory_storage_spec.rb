require 'spec_helper'

describe Perf::Storage::MemoryStorage do
  let(:counters) { Perf::Storage::MemoryStorage.new_storage_hash }
  let(:storage) { described_class.new(counters) }

  describe 'instance methods' do
    subject {storage}

    it {is_expected.to respond_to :increment}
    it {is_expected.to respond_to :increment_volatile}
    it {is_expected.to respond_to :decrement_volatile}
  end

  describe '#increment' do
    context 'with new counters' do
      it 'should increment' do
        storage.increment(foo: 1, bar: 5)

        expect(counters).to eq ({"foo" => 1, "bar" => 5})
      end
    end

    context 'existing counters' do
      before(:each) do
        counters[:foo] =  1
        counters[:bar] = 2
      end

      it 'should increment' do
        storage.increment(foo: 3, bar: 5)

        expect(counters).to eq({"foo" => 4, "bar" => 7})
      end
    end
  end

  describe '#increment_volatile' do
    it 'calls increment' do
      expect(storage).to receive(:increment).with(foo: 1, bar: 25)

      storage.increment_volatile({foo: 1, bar: 25})
    end

    it 'sets new and existing counters' do
      counters[:existing] = 5

      storage.increment_volatile(existing: 10, new: 25)

      expect(counters).to eq("existing" => 15, "new" => 25)
    end
  end

  describe '#decrement_volatile' do
    it 'decrements exising counters' do
      counters[:existing1] = 10
      counters[:existing2] = 15
      counters[:existing3] = 20

      storage.decrement_volatile(existing1: 2, existing2: 3)

      expect(counters).to eq({"existing1" => 8, "existing2" => 12, "existing3" => 20})
    end
  end

  describe '#all_counters' do
    let(:all_counters) { storage.all_counters }
    subject { all_counters }

    it { is_expected.to be_kind_of(Hash) }
    it { is_expected.to be_empty }


    it 'includes regular counters' do
      storage.increment(foo: 1, bar: 2)

      expect(all_counters).to eq({"foo" => 1, "bar" => 2})
    end

    it 'includes volatile counters' do
      storage.increment_volatile(foo: 1, bar: 2)

      expect(all_counters).to eq ({"foo" => 1, "bar" => 2})
    end
  end

  describe '#reset' do
    let(:all_counters) { storage.all_counters }

    it 'does not fail on an empty set' do
      expect { storage.reset }.not_to raise_error
    end

    it 'resets regular counters' do
      storage.increment(foo: 1, bar: 2)
      storage.reset
      expect(all_counters).to be_empty
    end

    it 'resets volatile counters' do
      storage.increment_volatile(foo: 1, bar: 2)
      storage.reset
      expect(all_counters).to be_empty
    end
  end
end
