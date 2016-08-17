require 'spec_helper'

describe Perf::Data do 
  let(:storage) { mock_storage }

  before(:each) do
    allow(Perf::Configuration).to receive(:storage).and_return(storage)
  end

  def mock_storage
    double('storage').tap do |s|
      allow(s).to receive(:all_counters)
      allow(s).to receive(:reset)
    end
  end

  describe '.get' do
    it 'redirects call to the storage' do
      expect(storage).to receive(:all_counters)

      Perf::Data.get
    end

    it 'returns value obtained from the storage' do
      expected = SecureRandom.uuid
      allow(storage).to receive(:all_counters).and_return(expected)

      expect(Perf::Data.get).to eq(expected)
    end
  end

  describe '.reset' do
    it 'redirects call to the storage' do
      expect(storage).to receive(:reset)

      Perf::Data.reset
    end
  end
end
