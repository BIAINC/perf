require 'spec_helper'
require 'uuid'

describe Perf::Data do 
  let(:storage) { mock_storage }

  before(:each) do
    Perf::Configuration.stub(:storage).and_return(storage)
  end

  def mock_storage
    s = double('storage')
    s.stub(:all_counters)
    s.stub(:reset)
    s
  end

  context '::get' do
    it 'should redirect call to the storage' do
      storage.should_receive(:all_counters)

      Perf::Data.get
    end

    it 'should return value obtained from the storage' do
      expected = UUID.generate.to_s
      storage.stub(:all_counters).and_return(expected)

      Perf::Data.get.should eql(expected)
    end
  end

  context '::reset' do
    it 'should redirect call to the storage' do
      storage.should_receive(:reset)

      Perf::Data.reset
    end
  end
end
