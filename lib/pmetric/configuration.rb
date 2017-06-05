module PMetric
  class Configuration
    attr_accessor \
      :collector,
      :host,
      :port,
      :username,
      :password,
      :database,
      :time_precision,
      :retry,
      :use_ssl,
      :logger,
      :async,
      :udp_host,
      :udp_port,
      :default_tags

    def initialize
      @host = ENV.fetch('INFLUXDB_HOST', 'influxdb.500friends.com'.freeze)
      @port = ENV.fetch('INFLUXDB_PORT', 8086)
      @username = ENV.fetch('INFLUXDB_USERNAME', nil)
      @password = ENV.fetch('INFLUXDB_PASSWORD', nil)
      @database = ENV.fetch('INFLUXDB_DATABASE', 'prism'.freeze)
      @time_precision = 'ns'.freeze
      @retry = 10
      @use_ssl = false

      # Logging is off by default
      @logger = false

      # PMetric must be intentionally enabled
      @collector = :noop

      # Async options
      @async = {
        # InfluxDB async writer uses a custom ruby Queue to keep track of
        # pending points, and this specifies the max number of items the queue
        # will allow. Anything greater will just drop off.
        max_queue_size: 10_000,

        # Number of post points to write at once. For a full queue with a max
        # size of 10_000, and a max post points of 1_000, it will take 10 batch
        # calls to post all the data.
        max_post_points: 1_000,

        # Number of Threads emptying the async queue. This will be per-process,
        # as the collector is shared globally.
        num_worker_threads: 2,

        # Time each thread waits to check for new points. The InfluxDB client
        # will actually sleep at `rand(sleep_interval)`, fyi.
        sleep_interval: 5
      }

      # Default to no udp_port. Setting udp_port && udp_host enables UDP on.
      @udp_host = ENV.fetch('INFLUXDB_UDP_HOST', @host)
      @udp_port = ENV.fetch('INFLUXDB_UDP_PORT', nil)

      # Default Event Tags
      @default_tags = nil
    end

    # Builds client options for the {PMetric::Collector::Influx}
    # collector.
    #
    # @return [Hash] Influx client options.
    def client_opts
      opts = {
        host: @host,
        port: @port,
        database: @database,
        time_precision: @time_precision,
        retry: @retry
      }

      opts[:username] = @username if @username
      opts[:password] = @password if @password

      if @use_ssl
        opts[:use_ssl] = true
        opts[:verify_ssl] = true
      end

      if @udp_host && @udp_port
        opts[:udp] = { host: @udp_host, port: @udp_port }
        opts[:async] = false
      else
        opts[:async] = @async || false
      end

      opts
    end
  end
end
