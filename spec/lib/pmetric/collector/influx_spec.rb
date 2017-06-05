require 'spec_helper'
require 'influxdb'

RSpec.describe PMetric::Collector::Influx do
  describe '#initialize' do
    before { @old_logger = InfluxDB::Logging.logger }
    after { InfluxDB::Logging.logger = @old_logger }

    it 'accepts default tags' do
      collector = described_class.new(tags: { tag: 'value' })
      expect(collector.tags).to eq(tag: 'value')
    end

    it 'sets precision from the options default tags' do
      collector = described_class.new(opts: { time_precision: 'x' })
      expect(collector.precision).to eq('x')
    end

    it 'sets a default precision' do
      collector = described_class.new
      expect(collector.precision).to eq('ns')
    end

    it 'accepts opts' do
      collector = described_class.new(opts: { var: 'value' })
      expect(collector.opts).to eq(var: 'value')
    end

    it 'sets the global InfluxDB logger' do
      collector = described_class.new
      expect(InfluxDB::Logging.logger).to be_a(PMetric::Collector::InfluxLogger)
    end
  end

  describe '#increment' do
    it 'delegates to write with a :value field equal to 1' do
      collector = described_class.new

      expect(collector).to receive(:write).
        with('key', fields: { value: 1 }, tags: { test: :tag }).
        and_return(nil)

      collector.increment('key', tags: { test: :tag })
    end
  end

  describe '#write' do
    it 'send the data to the InfluxDB client correctly' do
      expected_values = { test: :data }
      expected_tags = { given: :tag, default: :tag }

      client = double()
      expect(client).to receive(:write_point).
        with('key', hash_including(values: expected_values, tags: expected_tags)).
        and_return(nil)

      collector = described_class.new(tags: { default: :tag })
      allow(collector).to receive(:client).and_return(client)

      collector.write('key', fields: { test: :data }, tags: { given: :tag })
    end
  end
end
