module PMetric
  module Collector
    class Noop
      def increment(*_args); nil end

      def write(*_args); nil end
    end
  end
end
