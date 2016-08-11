require 'spec_helper'

describe Perf::FailuresCounter do
  let(:increments) { {foo: 1, bar: 2} }

  def active_counter
    counter = described_class.new(increments)
    counter.start
    counter
  end

  describe 'interface' do
    subject { Perf::FailuresCounter }

    it {is_expected.to be_a_counter }
  end
  
  describe '#start' do
    let(:counter) { described_class.new(increments) }

    before(:each) do
      stub_storage
    end

    it 'does not update storage' do
      # Storage is mocked up with no methods. Calling it will result in an error
      expect { counter.start }.to_not raise_error
    end
  end

  describe '#stop' do
    let(:counter) { active_counter }

    before(:each) do
      stub_storage
    end

    it 'does not update storage' do
      expect { counter.stop }.to_not raise_error
    end
  end

  describe '#error' do
    let(:counter) { active_counter }

    before(:each) do
      stub_storage
    end

    it 'updates storage' do
      expect(Perf::Configuration.storage).to receive(:increment).with(increments).once
      counter.error
    end

    it 'executes lambdas' do
      c = described_class.new({foo: 1, bar: ->{2}})
      c.start
      expect(Perf::Configuration.storage).to receive(:increment).with(foo: 1, bar: 2).once

      c.error
    end
  end
end
