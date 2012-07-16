# -*- encoding: utf-8 -*-
require File.expand_path('../lib/mongo_fe/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name = "mongo_fe"
  gem.version = MongoFe::VERSION
  gem.authors = ["Florin T.PATRASCU"]
  gem.email = %W(florin.patrascu@gmail.com)
  gem.summary = %q{Play and learn MongoDB or manage simple MongoDB administrative tasks}
  gem.description = %q{A simple Sinatra based web front-end that can be used for experimenting and learning MongoDB. The MongoFe gem can also be used for simple administrative tasks, managing collections and document basic operations such as: create new documents, delete existing ones, search by various criteria and document indexing.}
  gem.homepage = ""

  gem.files = `git ls-files`.split($\)
  gem.executables = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = %W(lib)
  gem.extra_rdoc_files = %w(LICENSE README.md)

  # Gem dependencies for runtime
  gem.add_runtime_dependency "hashie"
  gem.add_runtime_dependency "haml", "~> 3.1.4"
  gem.add_runtime_dependency "vegas", "~> 0.1.11"
  gem.add_runtime_dependency "chronic", "~> 0.6.7"
  gem.add_runtime_dependency "mongo", "~> 1.6.2"
  gem.add_runtime_dependency "yajl-ruby"
  gem.add_runtime_dependency "bson"
  gem.add_runtime_dependency "bson_ext"
  gem.add_runtime_dependency "json"
  gem.add_runtime_dependency 'will_paginate', '>= 3.0.0'
  gem.add_runtime_dependency 'will_paginate-bootstrap'
  gem.add_runtime_dependency "sinatra", "~> 1.3.2"
  gem.add_runtime_dependency "sinatra-contrib", "~> 1.3.1"
  gem.add_runtime_dependency 'redcarpet', '~> 2.1.0'
  gem.add_runtime_dependency 'coderay', '~> 1.0.5'
  gem.add_runtime_dependency 'tilt', '~> 1.3.0'

  # Gem dependencies for development
  gem.add_development_dependency "rspec", "~> 2.9"
  gem.add_development_dependency 'bundler', '~> 1.1.0'
  gem.add_development_dependency 'appraisal', '~> 0.4.1'
  gem.add_development_dependency 'cucumber'
  gem.add_development_dependency 'rspec', '~> 2.9.0'
  gem.add_development_dependency 'capybara', '~> 1.1.2'
  gem.add_development_dependency 'webrat', '~> 0.7.3'
  gem.add_development_dependency 'shoulda-matchers', '~> 1.1.0'
  gem.add_development_dependency "factory_girl", "~> 3.0"
  gem.add_development_dependency "simplecov", ">=0.4.2"
  gem.add_development_dependency "logger"

end
