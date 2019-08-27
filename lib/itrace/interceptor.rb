module ITrace
  class Interceptor < ::Module
    def initialize(log_switch, mod, methods_to_exclude, opts)
      @log_switch = log_switch
      intercepted_first_method = false
      interceptor = self

      mod.public_instance_methods.each do |method_sym|
        next if methods_to_exclude[method_sym]
        @module_name ||= produce_module_name(mod)

        unless intercepted_first_method
          log_module_interception if opts[:log_interception_of_modules]
          intercepted_first_method = true
        end

        method_name = method_sym.to_s
        log_method_interception(method_name) if opts[:log_interception_of_methods]

        define_method(method_sym) do |*args, &blk|
          interceptor.log_call(self, method_name, args)
          super(*args, &blk)
        end
      end

      mod.prepend(self)
    end

    def log_call(instance, method_name, args)
      @log_switch.debug('itrace') do
        args = args.map do |a|
          a = a.inspect
          a.size > 20 ? a[0, 17] + '...' : a
        end.join(', ')

        if @module_name == instance.class.name
          "#{get_instance_name(instance)}.#{method_name}(#{args})"
        else
          "#{get_instance_name(instance)}[#{@module_name}].#{method_name}(#{args})"
        end
      end
    end

  private
    def log_module_interception
      @log_switch.debug('itrace'){ "Intercepting #{@module_name}." }
    end

    def log_method_interception(module_name, method_name)
      @log_switch.debug('itrace'){ "Intercepting #{@module_name}\##{method_name}." }
    end

    def produce_module_name(mod)
      mod.singleton_class? ? 'singleton' : (mod.name || mod.object_id.to_s)
    end

    def get_instance_name(instance)
      @instance_names ||= {}
      @instance_names[instance.object_id] ||= produce_instance_name(instance)
    end

    def produce_instance_name(instance)
      instance_name = instance.is_a?(::Module) && instance.name
      instance_name ? "#{instance.class}:(#{instance.name})" : "#{instance.class}:#{instance.object_id}"
    end
  end
end
