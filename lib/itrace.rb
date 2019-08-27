require 'itrace/tracer'
require 'logger'

module ITrace
  def logger
    @logger ||= default_logger
  end

  def tracer
    @tracer ||= default_tracer
  end

  def trace(*modules, **opts, &blk)
    tracer.trace(*modules, **opts, &blk)
  end

  def enable_logging
    tracer.enable_logging
  end

  def disable_logging
    tracer.disable_logging
  end

private
  def default_logger
    @default_logger ||= begin
      logger = ::Logger.new($stderr)
      logger.level = ::Logger::DEBUG
      logger
    end
  end

  def default_tracer
    @default_tracer ||= Tracer.new(logger)
  end

  extend self
end
