require 'itrace'

class ITraceInstance
  include ITrace

  def initialize(logger = nil)
    @logger = logger
  end
end
