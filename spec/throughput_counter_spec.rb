require 'spec_helper'

describe Perf::ThroughputCounter do
  let(:storage) { Perf::Storage::MemoryStorage.new }

  before(:each) do
    allow(Perf::Configuration).to receive(:storage).and_return(storage)
  end

  describe 'interface' do
    subject { Perf::ThroughputCounter }

    it { is_expected.to be_a_counter }
  end

  describe '#start' do
    let(:counter_name) { :throughput }
    let(:volume) { rand(100..1000) }
    let(:counter) { Perf::ThroughputCounter.new(counter_name => volume) }

    it 'records start time' do
      expect(Time).to receive(:now).and_call_original

      counter.start
    end
  end

  describe '#stop' do
    let(:counter_name) { :throughput }

    before(:each) do
      allow(Time).to receive(:now).and_return(110, 120)
    end

    context 'normal counter' do
      let(:volume) { rand(100..1000) }
      let(:counter) { Perf::ThroughputCounter.new(counter_name => volume)}

      before(:each) do
        counter.start
      end

      it 'increments counters' do
        expect(storage).to receive(:increment).with("#{counter_name}_count" => 1, "#{counter_name}_duration" => 10000, "#{counter_name}_volume" => volume)

        counter.stop
      end
    end

    context 'lambda counter' do
      let(:volume) { -> { 123 } }
      let(:counter) { Perf::ThroughputCounter.new(counter_name => volume) }

      before(:each) do
        counter.start
      end

      it 'increments counters' do
        expect(storage).to receive(:increment).with("#{counter_name}_count" => 1, "#{counter_name}_duration" => 10000, "#{counter_name}_volume" => volume.call)

        counter.stop
      end
    end
  end

  describe '#error' do
    let(:counter_name) { :throughput }
    let(:volume) { rand(100..1000) }
    let(:counter) { Perf::ThroughputCounter.new(counter_name => volume) }

    before(:each) do
      counter.start
    end

    it 'does not increment counters' do
      expect(storage).not_to receive(:increment)

      counter.error
    end
  end
end
