require File.expand_path(File.join(%w{.. lib itrace version}), __FILE__)

Gem::Specification.new do |s|
  s.name        = "itrace"
  s.version     = ITrace::VERSION
  s.date        = "2019-08-27"
  s.summary     = "An intercepting tracer"
  s.description = "Prepends anonymous modules that intercept and log method calls"
  s.authors     = ["R.P. Pedraza"]
  s.email       = "rp.pedraza@gmail.com"
  s.homepage    = "https://rubygems.org/gems/itrace"
  s.license     = "MIT"
  s.metadata    = { "source_code_uri" => "https://github.com/rp-pedraza/itrace" }

  s.files = [
    "lib/itrace.rb",
    "lib/itrace/defaults.rb",
    "lib/itrace/interceptor.rb",
    "lib/itrace/log_switch.rb",
    "lib/itrace/not_a_module_error.rb",
    "lib/itrace/tracer.rb",
    "lib/itrace/version.rb",
    "lib/itrace_instance.rb",
    "test/test.rb"
  ]

  s.add_development_dependency "rake", "~> 12.3"
  s.add_development_dependency "minitest", "~> 5.11"
end
