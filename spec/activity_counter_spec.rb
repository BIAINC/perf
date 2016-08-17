require 'spec_helper'

describe Perf::ActivityCounter do
  let(:type) { Perf::ActivityCounter }
  let(:increments) { {foo: 1, bar: 2} }

  def mock_storage
    double('storage').tap do |s|
      allow(s).to receive(:increment)
      allow(s).to receive(:increment_volatile)
      allow(s).to receive(:decrement_volatile)
    end
  end

  def active_counter
    c = type.new(increments)
    c.start
    c
  end

  describe 'interface' do
    subject { Perf::ActivityCounter}

    it {is_expected.to be_a_counter }
  end

  describe '#start' do
    let(:counter) { type.new(increments) }

    before(:each) do
      stub_storage
    end

    it 'increments volatile counters' do
      expect(Perf::Configuration.storage).to receive(:increment_volatile).with(increments).once

      counter.start
    end
  end

  describe '#stop' do
    before(:each) do
      stub_storage(:increment_volatile)
    end

    it 'decrements volatile counters' do
      counter = active_counter

      # Make sure stopping an active counter calls decrement_volatile and nothing else.
      s = stub_storage
      expect(s).to receive(:decrement_volatile).with(increments).once

      counter.stop
    end
  end

  describe '#error' do
    before(:each) do
      allow(Perf::Configuration).to receive(:storage).and_return(mock_storage)
    end

    it 'decrements volatile counters' do
      counter = active_counter

      # Make sure we're calling only decrement_volatile, and only once
      s = double('storage')
      allow(Perf::Configuration).to receive(:storage).and_return(s)
      expect(s).to receive(:decrement_volatile).with(increments).once

      counter.error
    end
  end
end
