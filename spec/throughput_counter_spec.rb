require 'spec_helper'

describe Perf::ThroughputCounter do
  let(:storage) { Perf::Storage::MemoryStorage.new }

  before(:each) do
    Perf::Configuration.stub(:storage).and_return(storage)
  end

  context 'interface' do
    subject { Perf::ThroughputCounter }

    it { should be_a_counter }
  end

  context '#start' do
    let(:counter_name) { :throughput }
    let(:volume) { rand(100..1000) }
    let(:counter) { Perf::ThroughputCounter.new(counter_name => volume) }

    it 'should record start time' do
      Time.should_receive(:now).and_call_original

      counter.start
    end
  end

  context '#stop' do
    let(:counter_name) { :throughput }

    before(:each) do
      Time.stub(:now).and_return(110, 120)
    end

    context 'normal counter' do
      let(:volume) { rand(100..1000) }
      let(:counter) { Perf::ThroughputCounter.new(counter_name => volume)}

      before(:each) do
        counter.start
      end

      it 'should increment counters' do
        storage.should_receive(:increment).with("#{counter_name}_count" => 1, "#{counter_name}_duration" => 10000, "#{counter_name}_volume" => volume)

        counter.stop
      end
    end

    context 'lambda counter' do
      let(:volume) { -> { 123 } }
      let(:counter) { Perf::ThroughputCounter.new(counter_name => volume) }

      before(:each) do
        counter.start
      end

      it 'should increment counters' do
        storage.should_receive(:increment).with("#{counter_name}_count" => 1, "#{counter_name}_duration" => 10000, "#{counter_name}_volume" => volume.call)

        counter.stop
      end
    end
  end

  context '#error' do
    let(:counter_name) { :throughput }
    let(:volume) { rand(100..1000) }
    let(:counter) { Perf::ThroughputCounter.new(counter_name => volume) }

    before(:each) do
      counter.start
    end

    it 'should not increment counters' do
      storage.should_not_receive(:increment)

      counter.error
    end
  end
end