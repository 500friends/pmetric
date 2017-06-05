require 'pmetric/configuration'
require 'pmetric/collector'
require 'yaml'

module PMetric
  CONFIGURE_MUTEX ||= Mutex.new

  # Enables metric collection by setting the collector to `:influx`
  def self.enable!
    configure { |c| c.collector = :influx }
  end

  # Disables metric collection by setting the collector to `:noop`
  def self.disable!
    configure { |c| c.collector = :noop }
  end

  # Returns and caches the global collector.
  #
  # @return [PMetric::Collector::Base]
  def self.collector
    Thread.main[:pmetric_collector] ||= Collector.build(config)
  end

  # Returns the global configuration.
  #
  # Do not set values on this object. Use `#configure` instead.
  #
  # @return [PMetric::Configuration]
  def self.config
    Thread.main[:pmetric_config] ||= Configuration.new
  end

  # Yields the configuration for the current thread.
  #
  # @yield [PMetric::Configuration]
  def self.configure
    CONFIGURE_MUTEX.synchronize { yield config }
  end

  # Delegates to {PMetric.collector}. Collectors will add the `value: 1` field
  # on their own, so passing it here will be overridden later.
  #
  # @param metric [String] the item/event being measured
  # @param fields [Hash] additional field values to be recorded
  # @param tags [Hash] additional tags for this metric
  def self.increment(metric, fields: {}, tags: {})
    collector.increment(metric, fields: fields, tags: tags)
  end

  # Delegates to {PMetric.collector}.
  #
  # @param metric [String] the item/event being measured
  # @param fields [Hash] additional field values to be recorded
  # @param tags [Hash] additional tags for this metric
  def self.write(stat, fields:, tags: {})
    collector.write(stat, fields: fields, tags: tags)
  end

  # Loads a YAML configuration for the given file/environment.
  #
  # @param path [String] The path to the configuration file
  # @param env [String] The environment to load the configs for.
  def self.load_config_for_env(path, env)
    if !File.exists?(path)
      warn "[#{self.name}] Configuration file does not exist: #{path}"
      return
    end

    yaml = Hash(YAML.load_file(path))[env]

    if !yaml
      warn "[#{self.name}] Environment not configured at #{path}: #{env}"
      return
    end

    enable! if yaml['enabled']
    Hash(yaml['config']).each { |k, v| config.send("#{k}=", v) }
  end
end
