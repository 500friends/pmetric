require 'spec_helper'

RSpec.describe PMetric do
  describe '.collector' do
    around do |ex|
      described_class.with_clean_env { ex.run }
    end

    it 'calls Collector.build and caches the current collector' do
      expect(described_class::Collector).to receive(:build).
        with(described_class.config).
        once.
        and_return(:memoizable)

      collector = described_class.collector
      expect(collector).to eq(:memoizable)
      expect(collector).to eq(described_class.collector)
    end
  end

  describe '.enable!' do
    after { described_class.disable! }

    it 'sets the collector to :influx' do
      config = described_class.config
      described_class.enable!
      expect(config.collector).to eq(:influx)
    end
  end

  describe '.disable!' do
    it 'sets the collector to :noop' do
      config = described_class.config
      described_class.disable!
      expect(config.collector).to eq(:noop)
    end
  end

  describe '.config' do
    it 'returns and caches the current configuration' do
      config = described_class.config
      expect(config).to be_a(described_class::Configuration)
      expect(config).to eq(described_class.config)
    end
  end

  describe '.configure' do
    it 'yields the current configuration' do
      config = described_class.config
      described_class.configure do |yielded_config|
        expect(yielded_config).to eq(config)
      end
    end
  end

  describe '.increment' do
    it 'delegates to .collector' do
      collector = double()

      allow(described_class).to receive(:collector).
        and_return(collector)

      expect(collector).to receive(:increment).
        with('key', fields: { test: 1 }, tags: { tag: 1 })

      described_class.increment('key', fields: { test: 1 }, tags: { tag: 1 })
    end
  end

  describe '.write' do
    it 'delegates to .collector' do
      collector = double()

      allow(described_class).to receive(:collector).
        and_return(collector)

      expect(collector).to receive(:write).
        with('key', fields: { test: 1 }, tags: { tag: 1 })

      described_class.write('key', fields: { test: 1 }, tags: { tag: 1 })
    end
  end

  describe '.load_config_for_env' do
    let(:path) { 'spec/fixtures/metrics/config.yml' }

    it 'handles missing configuration files and warns' do
      expect(described_class).to receive(:warn).with(/file does not exist/)
      expect(YAML).to_not receive(:load_file)
      described_class.load_config_for_env('invalid_file.yml', 'invalid')
    end

    it 'handles invalid environments' do
      expect(described_class).to receive(:warn).with(/Environment not configured/)
      described_class.load_config_for_env(path, 'invalid')
    end

    it 'enables collection when configured' do
      expect(described_class).to receive(:enable!)
      described_class.load_config_for_env(path, 'enabled')
    end

    it 'does not enable collection when not configured' do
      expect(described_class).to_not receive(:enable!)
      described_class.load_config_for_env(path, 'disabled')
    end

    it 'updates the configuration from the file' do
      described_class.load_config_for_env(path, 'other')
      config = described_class.config
      expect(config.host).to eq("other.com")
      expect(config.port).to eq(9919)
      expect(config.database).to eq("other_database")
    end
  end
end
