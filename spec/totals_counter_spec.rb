require 'spec_helper'

describe Perf::TotalsCounter do 
  let(:type) { Perf::TotalsCounter }
  let(:increments) {{foo: 1, bar:2, lambda: ->{3}}}
  let(:translated_increments) { {foo: 1, bar: 2, lambda: 3} }

  def active_counter
    c = type.new(increments)
    c.start
    c
  end

  describe 'interface' do
    subject { Perf::TotalsCounter }

    it { is_expected.to be_a_counter }
  end

  describe '#start' do
    let(:counter) { type.new(increments) }

    before(:each) { stub_storage }

    it 'shdoes not update storage' do
      # Storage is stubbed; it has no methods.
      expect { counter.start }.to_not raise_error
    end
  end

  describe '#stop' do
    before(:each) do
      stub_storage
    end

    it 'updates storage' do
      counter = active_counter
      storage  = stub_storage

      expect(storage).to receive(:increment).with(translated_increments).exactly(1).times

      counter.stop
    end
  end

  describe '#error' do
    before(:each) do
      stub_storage
    end

    it 'does not update storage' do
      counter = active_counter
      stub_storage

      expect { counter.error }.to_not raise_error
    end
  end
end
