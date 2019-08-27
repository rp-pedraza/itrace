module ITrace
  class LogSwitch
    attr_reader :logger

    def initialize(logger, enable_logging = true)
      @logger = logger
      @logger_methods = {}
      @enable_logging = enable_logging
    end

    def enable_logging
      @enable_logging = true
      self
    end

    def disable_logging
      @enable_logging = false
      self
    end

    def call_logger(m_id, *args, &blk)
      get_logger_method(m_id).call(*args, &blk) if @enable_logging
    end

    def change_logger(logger)
      raise NotYetImplementedError
    end

  private
    class NotYetImplementedError < ::StandardError
      def initialize; super("Not yet implemented"); end
    end

    def get_logger_method(m_id)
      @logger_methods[m_id] ||= @logger.method(m_id)
    end

    def create_wrapper_method(m_id)
      logger_method = get_logger_method(m_id)

      define_singleton_method(m_id) do |*args, &blk|
        logger_method.call(*args, &blk) if @enable_logging
      end

      singleton_method(m_id)
    end

    def method_missing(m_id, *args, &blk)
      create_wrapper_method(m_id).call(*args, &blk)
    end
  end
end
