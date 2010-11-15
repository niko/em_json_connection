# encoding: utf-8

$:.unshift File.expand_path('../lib', __FILE__)
require 'em_json_connection/version'

Gem::Specification.new do |s|
  s.name         = "em_json_connection"
  s.version      = EmJsonConnection::VERSION
  s.authors      = ["Niko Dittmann"]
  s.email        = "mail+git@niko-dittmann.com"
  s.homepage     = "http://github.com/niko/em_json_connection"
  s.summary      = "Adds a JSON layer to a plain Eventmachine socket connection"
  s.description  = s.summary
  
  s.add_dependency "eventmachine"
  
  s.files        = Dir['lib/**/*.rb']
  s.test_files   = Dir['spec/**/*_spec.rb']
  
  s.platform     = Gem::Platform::RUBY
  s.require_path = 'lib'
  
  s.rubyforge_project = 'nowarning'
  s.add_development_dependency 'rspec'
end
