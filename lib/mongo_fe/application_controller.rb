require 'sinatra/base'
require 'sinatra/namespace'
require "mongo"
require 'haml'
require 'chronic'
require 'will_paginate'
require 'will_paginate/array'
require 'will_paginate/view_helpers/sinatra'
require 'will_paginate/view_helpers/link_renderer'

require 'redcarpet'

# require "mongo_fe/helpers/helpers"

require File.dirname(__FILE__) + '/helpers/helpers'

if defined? Encoding
  Encoding.default_external = Encoding::UTF_8
end

module MongoFe
  class ApplicationController < Sinatra::Base    
    use Rack::MethodOverride
    register Sinatra::Namespace
    register WillPaginate::Sinatra
    
    helpers do
      helpers Helpers
    end

    dbs = Hashie::Mash.new

    configure do
      enable :logging
      enable :sessions
    end

    dir = File.dirname(File.expand_path(__FILE__))
    set :views,  "#{dir}/views"

    if respond_to? :public_folder
      set :public_folder, "#{dir}/public"
    else
      set :public, "#{dir}/public"
    end

    set :static, true
    set :haml, { :format => :html5 }
    set :session_secret, "something_good" # must have if using shotgun during the development!
    
    get '/' do
      begin
        if current_db?
          redirect "/databases/#{current_db_name}"
        else
          haml :index
        end
      rescue =>e
        e.message
      end
    end        
    
    not_found do
      %Q(Sorry this page doesn't exist)
    end

  end

  class MarkdownRenderer < Redcarpet::Render::HTML
     include Redcarpet::Render::SmartyPants

     def block_code(code, language)
       CodeRay.highlight(code, language)
     end

     def escape_html(html)
       Rack::Utils.escape_html(html)
     end
  end
  
  # teach HAML how to use RedCarpet for markdown docs
  module Haml::Filters::Redcarpet
    include Haml::Filters::Base

    def render(text)
      Redcarpet::Markdown.new( MongoFe::MarkdownRenderer,
        :autolink => true, :space_after_headers => true, :fenced_code_blocks => true).
        render(text)
    end
  end
end