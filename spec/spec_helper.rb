ENV["RACK_ENV"] ||= "test"

require 'rack/test'
require "hashie/mash"
require 'yajl'
require 'cgi'
require "yaml"
require "mongo"
require "rspec"
require "SimpleCov"
require 'factory_girl'
require "webrat"
require 'shoulda-matchers'
require "sinatra/base"
require "sinatra/contrib"
require 'will_paginate'
require 'will_paginate/array'
require 'will_paginate/view_helpers/sinatra'
require 'will_paginate/view_helpers/link_renderer'

SimpleCov.start

Dir["./lib/**/*.rb"].each { |f| require f}

#load factories
Dir[File.dirname(__FILE__)+"/factories/*.rb"].each { |file| require file}

Webrat.configure do |conf|
  conf.mode = :rack
end


# see: http://bit.ly/KureJx, for a similar discussion
# and this is my solution:
module RSpecMixin
  include Rack::Test::Methods
  include Webrat::Methods
  include Webrat::Matchers
  include FactoryGirl::Syntax::Methods
  
  begin
    require "./lib/mongo_fe"
    
    config = Hashie::Mash.new (YAML.load(File.new(File.expand_path('~/.mongo_fe'))))
    MongoFe::MongoDB.uri = config.uri
  rescue
    puts "You must create a file in your home directory called .mongo_fe; error: #{$!.message}"
    exit 1
  end

  def self.app=(application)
    @app = application
  end
  
  def self.app
    @app
  end

  def app
    RSpecMixin.app ||= 
      Rack::Builder.new do
       Dir.glob('../lib/{mongo_fe,mongo_fe/helpers,mongo_fe/controllers}/*.rb').each { |file| require file }
       use MongoFe::ApplicationController
       use MongoFe::DatabasesController
       use MongoFe::CollectionsController

       run Sinatra::Base
      end
  end

  def request
    last_request
  end

  def session
    last_request.env['rack.session']
  end
  
end

RSpec.configure { |c| c.include RSpecMixin }

RSpec.configure do |c|
  c.include Rack::Test::Methods
  c.include Webrat::Methods
  c.include Webrat::Matchers
  c.include FactoryGirl::Syntax::Methods
end
