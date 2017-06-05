require 'spec_helper'

RSpec.describe PMetric::Configuration do
  let(:config) do
    described_class.new.tap { |c| c.udp_host = nil }
  end

  [
    :collector,
    :host,
    :port,
    :username,
    :password,
    :retry,
    :time_precision,
    :database,
    :use_ssl,
    :logger,
    :async,
    :udp_host,
    :udp_port,
    :default_tags
  ].each do |item|
    describe "##{item}" do
      it 'is readable and writable' do
        config.send("#{item}=", 123)
        expect(config.send(item)).to eq(123)
      end
    end
  end

  describe '#collector default' do
    it 'is set to :noop' do
      expect(config.collector).to eq(:noop)
    end
  end

  describe '#client_opts' do
    context 'when udp_host and udp_port are set' do
      before do
        config.udp_host = 'udp.host.com'
        config.udp_port = 8089
      end

      it 'returns the correct udp options' do
        expect(config.client_opts).to include(
          host: config.host,
          port: config.port,
          udp: { host: config.udp_host, port: config.udp_port }
        )
      end

      it 'sets :async to false' do
        expect(config.client_opts[:async]).to eq(false)
      end
    end

    context 'when udp_host is missing' do
      before { config.udp_host = nil }

      it 'does not include udp connect options' do
        expect(config.client_opts).to_not have_key(:udp)
      end
    end

    context 'when udp_port is missing' do
      before { config.udp_port = nil }

      it 'does not include udp connect options' do
        expect(config.client_opts).to_not have_key(:udp)
      end
    end

    shared_examples :includes_key do |key|
      it "includes #{key}" do
        config.send("#{key}=", 'value')
        expect(config.client_opts[key]).to eq('value')
      end
    end

    shared_examples :excludes_key do |key|
      it "excludes #{key} when not set" do
        config.send("#{key}=", nil)
        expect(config.client_opts).to_not have_key(key)
      end
    end

    include_examples :includes_key, :host
    include_examples :includes_key, :port
    include_examples :includes_key, :database
    include_examples :includes_key, :time_precision
    include_examples :includes_key, :retry

    include_examples :includes_key, :username
    include_examples :excludes_key, :username

    include_examples :includes_key, :password
    include_examples :excludes_key, :password

    it 'includes ssl opts when use_ssl is true' do
      config.use_ssl = true
      expect(config.client_opts[:use_ssl]).to eq(true)
      expect(config.client_opts[:verify_ssl]).to eq(true)
    end

    it 'does not include ssl opts when use_ssl is false' do
      config.use_ssl = false
      expect(config.client_opts).to_not have_key(:use_ssl)
      expect(config.client_opts).to_not have_key(:verify_ssl)
    end

    it 'sets async to false when not present' do
      config.async = nil
      expect(config.client_opts[:async]).to eq(false)
    end

    it 'sets async options when present' do
      config.async = { one: :option }
      expect(config.client_opts[:async]).to eq(one: :option)
    end
  end
end
