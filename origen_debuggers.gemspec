# coding: utf-8
config = File.expand_path('../config', __FILE__)
require "#{config}/version"

Gem::Specification.new do |spec|
  spec.name          = "origen_debuggers"
  spec.version       = OrigenDebuggers::VERSION
  spec.authors       = ["Stephen McGinty"]
  spec.email         = ["stephen.f.mfcginty@gmail.com"]
  spec.summary       = "Provides Origen tester models to drive bench debuggers such as the Segger J-Link."
  spec.homepage      = "http://origen-sdk.org/debuggers"

  spec.required_ruby_version     = '>= 1.9.3'
  spec.required_rubygems_version = '>= 1.8.11'

  # Only the files that are hit by these wildcards will be included in the
  # packaged gem, the default should hit everything in most cases but this will
  # need to be added to if you have any custom directories
  spec.files         = Dir["lib/**/*.rb", "templates/**/*", "config/**/*.rb",
                           "bin/*", "lib/tasks/**/*.rake", "pattern/**/*.rb",
                           "program/**/*.rb", "lib/origen_debuggers/**/*.txt"
                          ]
  spec.executables   = []
  spec.require_paths = ["lib"]

  # Add any gems that your plugin needs to run within a host application
  spec.add_runtime_dependency "origen", ">= 0.2.6"

  # Add any gems that your plugin needs for its development environment only
  spec.add_development_dependency "origen_doc_helpers", ">= 0.2.0"
  spec.add_development_dependency "origen_jtag", ">= 0.12.0"
end
