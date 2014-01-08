require 'spec_helper'

describe Perf::ActivityCounter do
  let(:type) { Perf::ActivityCounter }
  let(:increments) { {foo: 1, bar: 2} }

  def mock_storage
    s = double('storage')
    s.stub(:increment)
    s.stub(:increment_volatile)
    s.stub(:decrement_volatile)
    s
  end

  def active_counter
    c = type.new(increments)
    c.start
    c
  end

  context 'counter' do
    subject { type.instance_methods }

    it { should include(:start) }
    it { should include(:stop) }
    it { should include(:error)}
  end

  context '#start' do
    let(:counter) { type.new(increments) }

    before(:each) do
      stub_storage
    end

    it 'should increment volatile counters' do
      Perf::Configuration.storage.should_receive(:increment_volatile).with(increments).exactly(1).times

      counter.start
    end
  end

  context '#stop' do
    before(:each) do
      stub_storage(:increment_volatile)
    end

    it 'should decrement volatile counters' do
      counter = active_counter

      # Make sure stopping an active counter calls decrement_volatile and nothing else.
      s = stub_storage
      s.should_receive(:decrement_volatile).with(increments).exactly(1).times

      counter.stop
    end
  end

  context '#error' do
    before(:each) do
      Perf::Configuration.stub(:storage).and_return(mock_storage)
    end

    it 'should decrement volatile counters' do
      counter = active_counter

      # Make sure we're calling only decrement_volatile, and only once
      s = double('storage')
      Perf::Configuration.stub(:storage).and_return(s)
      s.should_receive(:decrement_volatile).with(increments).exactly(1).times

      counter.error
    end
  end
end