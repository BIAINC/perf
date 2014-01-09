require 'spec_helper'

describe Perf::DurationCounter do
  let(:storage) { Perf::Storage::MemoryStorage.new }

  before(:each) do
    Perf::Configuration.stub(:storage).and_return(storage)
  end

  context 'interface' do
    subject { Perf::DurationCounter }

    it { should be_a_counter }
  end

  context '#start' do
    let(:counter_name) { :duration_counter }
    let(:counter) { Perf::DurationCounter.new(counter_name) }

    it 'should record start time' do
      Time.should_receive(:now)

      counter.start
    end
  end

  context '#stop' do
    let(:counter_name) { :duration_counter }
    let(:counter) { Perf::DurationCounter.new(counter_name) }

    before(:each) do
      Time.stub(:now).and_return(10, 20)
      counter.start
    end

    it 'should report duration to the storage' do
      storage.should_receive(:increment).with(counter_name => 10)

      counter.stop
    end
  end

  context '#error' do
    let(:counter_name) { :duration_counter }
    let(:counter) { Perf::DurationCounter.new(counter_name) }

    before(:each) do
      counter.start
    end

    it 'should not update storage' do
      storage.should_not_receive(:increment)
      counter.error
    end
  end
end