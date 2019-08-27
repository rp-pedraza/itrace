require 'itrace/defaults'
require 'itrace/interceptor'
require 'itrace/log_switch'
require 'itrace/not_a_module_error'

module ITrace
  class Tracer
    def initialize(logger, enable_logging = true)
      @logger = logger
      @log_switch = ::ITrace::LogSwitch.new(@logger, enable_logging = true)
      @intercepted = {}
    end

    def trace(*modules, **opts)
      rause "Not an array: #{opts[:include_methods]}" unless opts[:include_methods].nil? || \
          opts[:include_methods].is_a?(Array)
      rause "Not an array: #{opts[:exclude_methods]}" unless opts[:exclude_methods].nil? || \
          opts[:exclude_methods].is_a?(Array)

      modules_to_exclude = (opts[:exclude_modules] || [])
          .map{ |e| [get_object_id(e, opts[:use_orig_object_id]), true] }.to_h
      methods_to_include = (opts[:include_methods] || []).map(&:to_sym)
      methods_to_exclude = (opts[:exclude_methods] || [])
          .concat(::ITrace::Defaults::METHODS_TO_EXCLUDE).map(&:to_sym)
          .reject{ |e| methods_to_include.include?(e) }.map{ |e| [e, true] }.to_h

      modules.flatten.each do |mod|
        unless mod.is_a?(::Module)
          if opts[:ignore_non_modules]
            @log_switch.warn("Ignoring non-module: #{get_object_id(mod, true)}")
          else
            raise ::ITrace::NotAModuleError.new(mod)
          end
        end

        intercept(mod, modules_to_exclude, methods_to_exclude, opts)
      end

      if block_given?
        begin
          yield
        ensure
          @log_switch.disable_logging
        end
      end

      self
    end

    def enable_logging
      @log_switch.enable_logging
      self
    end

    def disable_logging
      @log_switch.disable_logging
      self
    end

  private
    def intercept(mod, modules_to_exclude, methods_to_exclude, opts, done = {})
      return if mod.is_a?(::ITrace) || mod.is_a?(::ITrace::Interceptor)
      object_id = get_object_id(mod, opts[:use_orig_object_id])
      return if modules_to_exclude[object_id]
      return if done[object_id]
      done[object_id] = true

      unless @intercepted[mod.object_id]
        ::ITrace::Interceptor.new(@log_switch, mod, methods_to_exclude, opts)
        @intercepted[mod.object_id] = true
      end

      if opts[:include_singleton_classes]
        singleton_class = mod.singleton_class
        object_id = get_object_id(singleton_class, opts[:use_orig_object_id])

        unless @intercepted[object_id]
          ::ITrace::Interceptor.new(@log_switch, singleton_class, methods_to_exclude, opts)
          @intercepted[object_id] = true
        end
      end

      if opts[:recursive]
        mod.constants.each do |const|
          begin
            submod = get_const_get_method(mod, opts[:use_orig_const_get]).call(const)
          rescue Exception => e
            if opts[:ignore_exceptions] && opts[:ignore_exceptions].any?{ |k| e.class == k }
              @log_switch.warn('itrace'){ "Ignoring caught exceptoin: #{e.class.name}" }
              next
            end

            raise e
          end

          if submod.is_a?(::Module)
            intercept(mod, modules_to_exclude, methods_to_exclude, opts, done)
          end
        end
      end
    end

    def get_const_get_method(mod, get_original)
      method = mod.method(:const_get)

      if get_original
        until method.owner == ::Module
          super_method = method.super_method or return method
          method = super_method
        end
      end

      return method
    end

    def get_object_id(obj, get_original)
      method = obj.method(:object_id)

      if get_original
        until method.owner == ::Kernel
          super_method = method.super_method or return method.call
          method = super_method
        end
      end

      return method.call
    end
  end
end
