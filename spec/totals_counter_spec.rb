require 'spec_helper'

describe Perf::TotalsCounter do 
  let(:type) { Perf::TotalsCounter }
  let(:increments) {{foo: 1, bar:2}}

  def active_counter
    c = type.new(increments)
    c.start
    c
  end

  context 'interface' do
    subject { Perf::TotalsCounter }
    it { should be_a_counter }
  end

  context '#start' do
    let(:counter) { type.new(increments) }

    before(:each) { stub_storage }

    it 'should not update storage' do
      # Storage is stubbed; it has no methods.
      expect { counter.start }.to_not raise_error
    end
  end

  context '#stop' do
    before(:each) do
      stub_storage
    end

    it 'should update storage' do
      counter = active_counter
      storage  = stub_storage

      storage.should_receive(:increment).with(increments).exactly(1).times

      counter.stop
    end
  end

  context '#error' do
    before(:each) do
      stub_storage
    end

    it 'should not update storage' do
      counter = active_counter
      stub_storage

      expect { counter.error }.to_not raise_error
    end
  end
end