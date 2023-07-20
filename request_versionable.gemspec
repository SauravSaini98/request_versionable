# -*- encoding: utf-8 -*-
require File.expand_path("../lib/request_versionable/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "request_versionable"
  s.version     = RequestVersionable::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = %w(sainisaurav019@gmail.com)
  s.email       = %w(sainisaurav019@gmail.com)
  s.homepage    = "https://github.com/sauravsaini98/request_versionable"
  s.license     = 'MIT'
  s.summary     = "RequestVersionable is a re-implementation of save_as_versions for Rails 3, 4, and 5, using much, much, much less code."
  s.description = <<-DSC
    RequestVersionable is gem used to save history for same table
  DSC

  s.required_rubygems_version = ">= 1.3.6"

  s.required_ruby_version = '>= 2.5'
  s.add_dependency 'activerecord', '>= 5.1'
  s.add_dependency 'request_store', '~> 1.5'

  s.add_development_dependency "bundler", ">= 1.0.0"
  s.add_development_dependency "rake"


  s.files = Dir.chdir(File.expand_path('..', __FILE__)) do
    files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)})  }
    files
  end

  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end
