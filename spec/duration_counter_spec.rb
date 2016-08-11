require 'spec_helper'

describe Perf::DurationCounter do
  let(:storage) { Perf::Storage::MemoryStorage.new }

  before(:each) do
    allow(Perf::Configuration).to receive(:storage).and_return(storage)
  end

  describe 'interface' do
    subject { Perf::DurationCounter }

    it { is_expected.to be_a_counter }
  end

  describe '#start' do
    let(:counter_name) { :duration_counter }
    let(:counter) { Perf::DurationCounter.new(counter_name) }

    it 'records start time' do
      expect(Time).to receive(:now).and_call_original

      counter.start
    end
  end

  describe '#stop' do
    let(:counter_name) { :duration_counter }
    let(:counter) { Perf::DurationCounter.new(counter_name) }

    before(:each) do
      allow(Time).to receive(:now).and_return(10, 20)
      counter.start
    end

    it 'reports duration to the storage' do
      expect(storage).to receive(:increment).with(counter_name => 10000)

      counter.stop
    end
  end

  describe '#error' do
    let(:counter_name) { :duration_counter }
    let(:counter) { Perf::DurationCounter.new(counter_name) }

    before(:each) do
      counter.start
    end

    it 'does not update storage' do
      expect(storage).not_to receive(:increment)
      counter.error
    end
  end
end