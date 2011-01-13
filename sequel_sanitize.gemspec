#!/usr/bin/env gem build
# -*- encoding: utf-8 -*-
require 'date'
require 'lib/sequel_sanitize/version'

Gem::Specification.new do |gem|
  gem.name     = 'sequel_sanitize'
  gem.version  = Sequel::Plugins::Sanitize::VERSION.dup
  gem.authors  = ['Kevin Tom']
  gem.date     = Date.today.to_s
  gem.email = 'kevin@kevintom.com'
  gem.homepage = 'http://github.com/kevintom/sequel_sanitize'
  gem.summary = 'Sequel plugin which lets you set a sanitization method on specific fields'
  gem.description = gem.summary

  gem.has_rdoc = true 
  gem.require_paths = ['lib']
  gem.extra_rdoc_files = ['README.rdoc', 'LICENSE', 'CHANGELOG']
  gem.files = Dir['Rakefile', '{lib}/**/*', 'README*', 'LICENSE*', 'CHANGELOG*'] & `git ls-files -z`.split("\0")

  gem.add_dependency 'sequel', ">= 3.0.0"
end
