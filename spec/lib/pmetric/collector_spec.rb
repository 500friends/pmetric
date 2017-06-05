require 'spec_helper'

RSpec.describe PMetric::Collector do
  let(:config) { PMetric::Configuration.new }

  describe '.build' do
    context 'when collector is set to :noop' do
      it 'returns a Noop collector' do
        config.collector = :noop
        collector = described_class.build(config)
        expect(collector).to be_a(described_class::Noop)
      end
    end

    context 'when collector is set to :influxdb' do
      it 'returns a correctly configured Influx collector' do
        config.collector = :influx
        config.default_tags = { default: :tag }

        collector = described_class.build(config)
        expect(collector).to be_a(described_class::Influx)
        expect(collector.tags).to eq(config.default_tags)
        expect(collector.opts).to eq(config.client_opts)
      end
    end
  end
end
