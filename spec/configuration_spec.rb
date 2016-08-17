describe Perf::Configuration do
  let(:configuration) { Object.new.extend(described_class) }

  describe '.storage' do
    it 'returns memory storage by default' do
      expect(configuration.storage).to be_kind_of(Perf::Storage::MemoryStorage)
    end

    it 'returns assigned storage' do
      storage = double('storage')
      configuration.storage = storage
      expect(configuration.storage).to be storage
    end

    it 'resets assigned storage' do
      storage = double('storage')
      configuration.storage = storage
      configuration.storage = nil
      expect(configuration.storage).to be_kind_of Perf::Storage::MemoryStorage
    end
  end

  describe '.activity_ttl_seconds' do
    it 'has a default value' do
      expect(configuration.activity_ttl_seconds).to eq Perf::Configuration::DEFAULT_ACTIVITY_TTL
    end

    it 'accepts non-default value' do
      configuration.activity_ttl_seconds = 2 * Perf::Configuration::DEFAULT_ACTIVITY_TTL
      expect(configuration.activity_ttl_seconds).to eq 2 * Perf::Configuration::DEFAULT_ACTIVITY_TTL
    end

    it 'resets to default value' do
      configuration.activity_ttl_seconds = 2 * Perf::Configuration::DEFAULT_ACTIVITY_TTL
      configuration.activity_ttl_seconds = nil
      expect(configuration.activity_ttl_seconds). to eq Perf::Configuration::DEFAULT_ACTIVITY_TTL
    end
  end

  context '.logger' do
    it 'has a default value' do
      expect(configuration.logger).not_to be_nil
    end

    it 'accepts non-default value' do
      logger = double('logger')
      configuration.logger = logger
      expect(configuration.logger).to be logger
    end

    it 'resets to default value' do
      configuration.logger = double('logger')
      configuration.logger = nil
      expect(configuration.logger).not_to be_nil
    end
  end
end
