require 'spec_helper'

describe Perf::HitsCounter do
  let(:type) { Perf::HitsCounter }
  let(:increments) { {foo: 1, bar: 2} }

  def active_counter
    c = type.new(increments)
    c.start
    c
  end

  context 'counter' do
    subject { type.instance_methods }

    it {should include(:start)}
    it {should include(:stop)}
    it {should include(:error)}
  end

  context '#start' do
    let(:counter) { type.new(increments) }
    before(:each) do
      stub_storage
    end

    it 'should update storage' do
      Perf::Configuration.storage.should_receive(:increment).with(increments).exactly(1).times

      counter.start
    end
  end

  context '#stop' do
    before(:each) do
      stub_storage(:increment)
    end

    it 'should not update storage' do
      counter = active_counter
      stub_storage

      # Stopping the counter will fail if it uses any storage methods - the mocked storage object doesn't have them.
      expect { counter.stop }.to_not raise_error
    end
  end

  context '#error' do
    before(:each) do
      stub_storage(:increment)
    end

    it 'should not update storage' do
      counter = active_counter
      stub_storage

      expect { counter.error }.to_not raise_error
    end
  end
end