# -*- encoding: utf-8 -*-

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "arthropod/version"

Gem::Specification.new do |gem|
  gem.name          = "arthropod"
  gem.version       = Arthropod::VERSION
  gem.authors       = ["Victor Goya"]
  gem.email         = ["goya.victor@gmail.com"]
  gem.description   = "Easy remote task execution with SQS"
  gem.summary       = "Execute ruby task on another server synchronously using Amazon SQS"

  gem.files         = `git ls-files -z`.split("\x0")
  gem.require_paths = ["lib"]

  gem.licenses      = ["MIT"]

  gem.add_dependency 'aws-sdk-sqs'

  gem.required_ruby_version = "~> 2.0"

  gem.add_development_dependency 'bundler'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'rake'
end
