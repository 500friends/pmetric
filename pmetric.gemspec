# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pmetric/version'

Gem::Specification.new do |spec|
  spec.name          = "pmetric"
  spec.version       = PMetric::VERSION
  spec.authors       = ["Braden Schaeffer"]
  spec.email         = ["bschaeffer@merkleinc.com"]

  spec.summary       = %q{InfluxDB Metrics for Rails apps.}
  spec.description   = %q{Enables configurable metric collection for Rails apps.}
  spec.homepage      = "https://github.com/500friends/pmetric"

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(spec)/})
  end

  spec.require_paths = ["lib"]

  # Monitoring Gems
  spec.add_dependency 'influxdb', '~> 0.3.14'
  spec.add_dependency 'activesupport', '>= 3.2.22', '< 6'

  spec.add_development_dependency 'appraisal'
  spec.add_development_dependency 'rspec_junit_formatter'
  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
