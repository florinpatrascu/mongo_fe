$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')

require 'bundler'
require "hashie/mash"
require 'cgi'
require "yaml"
require 'sinatra/base'
require 'mongo'
require 'mongo_fe'

begin
  config = Hashie::Mash.new (YAML.load(File.new(File.expand_path('~/.mongo_fe')))) || 'localhost:27017'
  MongoFe::MongoDB.uri = config.uri
rescue
  $stderr.print "You must create a file in your home directory called .mongo_fe; error: #{$!.message}"
  exit 1
end

# Encoding.default_internal = 'utf-8' 
# Encoding.default_external = 'utf-8'

Dir.glob('../lib/{mongo_fe,mongo_fe/helpers,mongo_fe/controllers}/*.rb').each { |file| require file }

use MongoFe::ApplicationController
use MongoFe::DatabasesController
use MongoFe::CollectionsController

run Sinatra::Base
