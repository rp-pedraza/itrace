require 'minitest/autorun'
require 'itrace'
require 'itrace_instance'

class Sample
  class Another
    def sample(*args)
      puts "Sample::Another#sample: #{args.join(' ')}"
    end
  end

  def sample(*args)
    puts "Sample#sample: #{args.join(' ')}"
  end
end

describe ITrace do
  it "logs method calls using default logger" do
    ITrace.trace(Sample, recursive: true, include_singleton_classes: true) do
      Sample.new.sample(1, 2, 3)
      Sample::Another.new.sample(:a, :b, :c)
    end
  end
end

describe ITraceInstance do
  it "instantiates and logs method calls using default logger" do
    ITraceInstance.new.trace(Sample, recursive: true, include_singleton_classes: true) do
      Sample.new.sample(1, 2, 3)
      Sample::Another.new.sample(:a, :b, :c)
    end
  end
end
