module PMetric
  def self.with_clean_env
    old_config = Thread.main[:pmetric_config]
    Thread.main[:pmetric_config] = nil

    old_collector = Thread.main[:pmetric_collector]
    Thread.main[:pmetric_collector] = nil

    yield

    Thread.main[:pmetric_config] = old_config
    Thread.main[:pmetric_collector] = old_collector
  end
end
