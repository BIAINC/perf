require 'spec_helper'

describe Perf::HitsCounter do
  let(:increments) { {foo: 1, bar: 2} }

  def active_counter
    c = described_class.new(increments)
    c.start
    c
  end

  describe 'interface' do
    subject { Perf::HitsCounter }

    it {is_expected.to be_a_counter }
  end

  describe '#start' do
    let(:counter) { described_class.new(increments) }

    before(:each) do
      stub_storage
    end

    it 'updates storage' do
      expect(Perf::Configuration.storage).to receive(:increment).with(increments).once

      counter.start
    end
  end

  describe '#stop' do
    before(:each) do
      stub_storage(:increment)
    end

    it 'does not update storage' do
      counter = active_counter
      stub_storage

      # Stopping the counter will fail if it uses any storage methods - the mocked storage object doesn't have them.
      expect { counter.stop }.to_not raise_error
    end
  end

  describe '#error' do
    before(:each) do
      stub_storage(:increment)
    end

    it 'does not update storage' do
      counter = active_counter
      stub_storage

      expect { counter.error }.to_not raise_error
    end
  end
end