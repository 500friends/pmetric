require 'pmetric/collector/base'
require 'pmetric/collector/noop'
require 'pmetric/collector/influx'

module PMetric
  module Collector
    # Builds a collector based on the given {PMetric.config} configuration.
    #
    # @param config [PMetric::Configuration]
    # @return [PMetric::Collector::Base]
    def self.build(config)
      collector = config.collector
      case collector.to_sym
      when :noop then Collector::Noop.new
      when :influx then build_influx_client(config)
      else
        raise "Invalid collector configured: #{collector.inspect}"
      end
    end

    # :nodoc:
    def self.build_influx_client(config)
      Collector::Influx.new(
        opts: config.client_opts,
        tags: config.default_tags,
        logger: config.logger
      )
    end
  end
end
