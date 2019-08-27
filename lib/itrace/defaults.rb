module ITrace
  module Defaults
    METHODS_TO_EXCLUDE = ::Kernel.instance_methods + ::Module.instance_methods
  end
end
