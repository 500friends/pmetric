module PMetric
  module Collector
    class Base
      def increment(_)
        raise NotImplementedError
      end

      def write(_)
        raise NotImplementedError
      end
    end
  end
end
