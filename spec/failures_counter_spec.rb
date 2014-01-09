require 'spec_helper'

describe Perf::FailuresCounter do
  let(:type) { Perf::FailuresCounter }
  let(:increments) { {foo: 1, bar: 2} }

  def active_counter
    counter = type.new(increments)
    counter.start
    counter
  end

  context 'interface' do
    subject { Perf::FailuresCounter }

    it {should be_a_counter }
  end
  
  context '#start' do
    let(:counter) { type.new(increments) }

    before(:each) do
      stub_storage
    end

    it 'should not update storage' do
      # Storage is mocked up with no methods. Calling it will result in an error
      expect { counter.start }.to_not raise_error
    end
  end

  context '#stop' do
    let(:counter) { active_counter }

    before(:each) do
      stub_storage
    end

    it 'should not update storage' do
      expect { counter.stop }.to_not raise_error
    end
  end

  context '#error' do
    let(:counter) { active_counter }

    before(:each) do
      stub_storage
    end

    it 'should update storage' do
      Perf::Configuration.storage.should_receive(:increment).with(increments).exactly(1).times

      counter.error
    end
  end
end
