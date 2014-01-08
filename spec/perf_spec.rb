require 'spec_helper'

describe Perf do
  include Perf

  def new_mock_counter
    counter = double('fake counter')
    counter.stub!(:start)
    counter.stub!(:stop)
    counter.stub!(:error)
    counter
  end

  context ':collect' do
    let(:counter) { new_mock_counter }

    it 'should call the code block' do
      called = false
      collect counter do
        called = true
      end
      called.should be_true
    end

    it 'should not fail without a code block' do
      expect { collect(counter) }.to_not raise_error
    end

    it 'should start a counter' do
      counter.should_receive(:start)

      collect(counter)
    end

    context 'without failure' do
      it 'should stop a counter' do
        counter.should_receive(:stop)
        collect(counter)
      end

      it 'should not receive error' do
        counter.should_not_receive(:error)
        collect(counter)
      end

      it 'should preserve the return value' do
        expected = Random.rand(0..99)
        actual = collect(counter) { expected }
        actual.should eql(expected)
      end
    end

    context 'with failure' do
      def with_failure
        collect(counter) { raise 'Test' }
      end

      it 'should preserve original exception' do
        expect{with_failure}.to raise_error('Test')
      end

      it 'should error counter' do
        counter.should_receive(:error)
        with_failure rescue nil
      end

      it 'should not stop counter' do
        counter.should_not_receive(:stop)
        with_failure rescue nil
      end
    end
  end

  context ':activity' do
    it 'should instantiate activity counter' do
      Perf::ActivityCounter.should_receive(:new)

      activity(:foo)
    end

    it 'should return an activity counter' do
      activity(:foo).should be_kind_of(Perf::ActivityCounter)
    end

    it 'should translate list of counters' do
      Perf::ActivityCounter.should_receive(:new).with({foo: 1, bar: 1}).and_call_original
      activity(:foo, :bar)
    end

    it 'should translate hash of counters' do
      Perf::ActivityCounter.should_receive(:new).with({foo: 5, bar: 10}).and_call_original
      activity(foo: 5, bar: 10)
    end

    it 'should translate mixed counters' do
      Perf::ActivityCounter.should_receive(:new).with({i1: 1, i2: 1, h1: 10, h2: 20})
      activity(:i1, :i2, h1: 10, h2:20)
    end
  end

  context 'totals' do
    it 'should instantiate a totals counter' do
      totals(:foo).should be_kind_of(Perf::TotalsCounter)
    end

    it 'should pass correct arguments to the totals counter' do
      Perf::TotalsCounter.should_receive(:new).with({foo: 1, bar: 10}).and_call_original
      totals(:foo, bar: 10)
    end
  end

  context 'hits' do
    it 'should instantiate a hita counter' do
      hits(:foo).should be_kind_of(Perf::HitsCounter)
    end

    it 'should pass correct arguments to the hits counter' do
      Perf::HitsCounter.should_receive(:new).with(foo: 1, bar: 10).and_call_original
      hits(:foo, bar: 10)
    end
  end

  context 'failures' do
    it 'should instantiate a failures counter' do
      failures(:foo).should be_kind_of(Perf::FailuresCounter)
    end

    it 'should pass correct arguments to the failures counter' do
      Perf::FailuresCounter.should_receive(:new).with({foo: 1, bar: 10}).and_call_original
      failures(:foo, bar: 10)
    end
  end
end
