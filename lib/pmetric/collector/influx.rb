module PMetric
  module Collector
    # InfluxDB Collector for {Pmetrics}.
    class Influx < Base
      PRECISIONS = {
        's' => Proc.new { Time.now.utc.to_i },
        'ms' => Proc.new { (Time.now.utc * 1000.0).to_i },
        'ns' => Proc.new { (Time.now.utc.to_r * 10**9).to_i }
      }.freeze

      attr_reader :tags, :precision, :opts, :logger

      # @param database [String] InfluxDB database to write to.
      # @param client_opts [Hash] InfluxDB client options.
      # @param tags [Hash] Default tags to be added to every event.
      # @param logger [Logger] InfluxDB client logger. This affects global InfluxDB logging.
      def initialize(opts: {}, tags: nil, logger: nil)
        @opts = opts
        @tags = Hash(tags).freeze
        @precision = (opts[:time_precision] || 'ns').freeze

        require 'influxdb'
        InfluxDB::Logging.logger = InfluxLogger.new(logger)
      end

      # Delegates to {#write}, adding `value: 1` to the fields. Passing
      # your own `value` field option is pointless here.
      #
      # @param metric [String] The item/event being measured.
      # @param fields [Hash] Additional fields being measured.
      # @param tags [Hash] Additional tags for the event.
      def increment(metric, fields: {}, tags: {})
        fields[:value] = 1
        write(metric, fields: fields, tags: tags)
      end

      # Writes metrics to InfluxDB.
      #
      # @param metric [String] The item/event being measured.
      # @param fields [Hash] The fields being measured.
      # @param tags [Hash] Additional tags for the event.
      def write(metric, fields:, tags: {})
        data = {
          values: fields,
          tags: tags.merge(@tags),
          timestamp: PRECISIONS[@precision].call
        }

        client.write_point(metric, data)
      end

      private

      def client
        @client ||= InfluxDB::Client.new(@opts)
      end
    end

    # Custom InfluxDB logger to set the logging prefix correctly.
    #
    # @private
    # :nodoc:
    class InfluxLogger
      def initialize(logger = nil)
        require 'active_support/tagged_logging'
        @logger = logger && ActiveSupport::TaggedLogging.new(logger)
      end

      %i(debug info warn error fatal).each do |level|
        define_method(level) do |prefix, &block|
          write(level, prefix, &block)
        end
      end

      def write(level, prefix, &block)
        @logger && @logger.tagged(prefix) { |l| l.send(level, &block) }
      end
    end
  end
end
