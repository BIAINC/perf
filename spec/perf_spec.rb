require 'spec_helper'

describe Perf do
  include Perf

  def new_mock_counter
    counter = double('fake counter')
    [:start, :stop, :error].each{|m| allow(counter).to receive(m)}
    counter
  end

  describe '.collect' do
    let(:counter) { new_mock_counter }

    it 'calls the code block' do
      expect{|b| collect(counter, &b)}.to yield_control
    end

    it 'does not fail without a code block' do
      expect { collect(counter) }.not_to raise_error
    end

    it 'starts a counter' do
      expect(counter).to receive(:start)

      collect(counter)
    end

    context 'without failure' do
      it 'stops a counter' do
        expect(counter).to receive(:stop)
        collect(counter)
      end

      it 'does not receive error' do
        expect(counter).not_to receive(:error)
        collect(counter)
      end

      it 'preserves the return value' do
        expected = Random.rand(0..99)
        actual = collect(counter) { expected }
        expect(actual).to eq expected
      end
    end

    context 'with failure' do
      def with_failure
        collect(counter) { raise 'Test' }
      end

      it 'preserves original exception' do
        expect{with_failure}.to raise_error('Test')
      end

      it 'calls error handler' do
        expect(counter).to receive(:error)
        with_failure rescue nil
      end

      it 'does not stop counter' do
        expect(counter).not_to receive(:stop)
        with_failure rescue nil
      end
    end
  end

  describe '.activity' do
    it 'instantiates activity counter' do
      expect(Perf::ActivityCounter).to receive(:new).once.and_call_original

      activity(:foo)
    end

    it 'returns an activity counter' do
      expect(activity(:foo)).to be_kind_of(Perf::ActivityCounter)
    end

    it 'translates list of counters' do
      expect(Perf::ActivityCounter).to receive(:new).with({foo: 1, bar: 1}).and_call_original
      activity(:foo, :bar)
    end

    it 'translates hash of counters' do
      expect(Perf::ActivityCounter).to receive(:new).with({foo: 5, bar: 10}).and_call_original
      activity(foo: 5, bar: 10)
    end

    it 'translates mixed counters' do
      expect(Perf::ActivityCounter).to receive(:new).with({i1: 1, i2: 1, h1: 10, h2: 20})
      activity(:i1, :i2, h1: 10, h2:20)
    end
  end

  describe '.totals' do
    it 'instantiates a totals counter' do
      expect(totals(:foo)).to be_kind_of(Perf::TotalsCounter)
    end

    it 'passes correct arguments to the totals counter' do
      expect(Perf::TotalsCounter).to receive(:new).with({foo: 1, bar: 10}).and_call_original
      totals(:foo, bar: 10)
    end
  end

  describe 'hits' do
    it 'instantiates a hita counter' do
      expect(hits(:foo)).to be_kind_of(Perf::HitsCounter)
    end

    it 'passes correct arguments to the hits counter' do
      expect(Perf::HitsCounter).to receive(:new).with(foo: 1, bar: 10).and_call_original
      hits(:foo, bar: 10)
    end
  end

  describe '.failures' do
    it 'instantiates a failures counter' do
      expect(failures(:foo)).to be_kind_of(Perf::FailuresCounter)
    end

    it 'passes correct arguments to the failures counter' do
      expect(Perf::FailuresCounter).to receive(:new).with({foo: 1, bar: 10}).and_call_original
      failures(:foo, bar: 10)
    end
  end

  describe '.duration' do
    it 'instantiates a duration counter' do
      expect(Perf::DurationCounter).to receive(:new).with(:foo).and_call_original
      duration(:foo)
    end

    it 'returns duration counter' do
      expect(duration(:foo)).to be_kind_of(Perf::DurationCounter)
    end
  end

  describe '.throughput' do
    it 'instantiates a throughput counter' do
      expect(Perf::ThroughputCounter).to receive(:new).with(foo: 123, bar: 456).and_call_original
      throughput(foo: 123, bar: 456)
    end

    it 'returns a throughput counter' do
      expect(throughput(foo: 123)).to be_a(Perf::ThroughputCounter)
    end
  end
end
