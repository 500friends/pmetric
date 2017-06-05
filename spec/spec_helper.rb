$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "pmetric"
require "pmetric/testing"

RSpec.configure do |config|
  config.disable_monkey_patching!

  config.expect_with :rspec

  config.mock_with :rspec do |mock|
    mock.verify_partial_doubles = true
  end

  config.filter_run_when_matching :focus

  # Many RSpec users commonly either run the entire suite or an individual
  # file, and it's useful to allow more verbose output when running an
  # individual spec file.
  if config.files_to_run.one?
    config.default_formatter = "doc"
  end

  config.order = :random
  Kernel.srand config.seed
end
