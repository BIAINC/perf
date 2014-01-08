describe Perf::Configuration do
  let(:configuration) { Perf::Configuration }

  before(:each) do
    configuration.storage = nil
    configuration.activity_ttl_seconds = nil
  end

  context '::storage' do
    it 'should return memory storage by default' do
      configuration.storage.should be_kind_of(Perf::Storage::MemoryStorage)
    end

    it 'should return assigned storage' do
      storage = double('storage')
      configuration.storage = storage
      configuration.storage.should eql(storage)
    end

    it 'should reset assigned storage' do
      storage = double('storage')
      configuration.storage = storage
      configuration.storage = nil
      configuration.storage.should be_kind_of(Perf::Storage::MemoryStorage)
    end
  end

  context '::activity_ttl_seconds' do
    it 'should have a default value' do
      configuration.activity_ttl_seconds.should eql(Perf::Configuration::DEFAULT_ACTIVITY_TTL)
    end

    it 'should accept non-default value' do
      configuration.activity_ttl_seconds = 2 * Perf::Configuration::DEFAULT_ACTIVITY_TTL
      configuration.activity_ttl_seconds.should eql(2 * Perf::Configuration::DEFAULT_ACTIVITY_TTL)
    end

    it 'should reset to default value' do
      configuration.activity_ttl_seconds = 2 * Perf::Configuration::DEFAULT_ACTIVITY_TTL
      configuration.activity_ttl_seconds = nil
      configuration.activity_ttl_seconds.should eql(Perf::Configuration::DEFAULT_ACTIVITY_TTL)
    end
  end
end
