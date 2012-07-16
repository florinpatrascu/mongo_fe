require "json"
require "bson"
require 'will_paginate'
require 'will_paginate/view_helpers/base'
require 'will_paginate/view_helpers/link_renderer'

module Helpers
  include Rack::Utils
  include WillPaginate::ViewHelpers::Base

  alias_method :h, :escape_html

  def current_page
    url_path request.path_info.sub('/', '')
  end

  def url_path(*path_parts)
    [path_prefix, path_parts].join("/").squeeze('/')
  end

  alias_method :u, :url_path

  def current_db?
    true if session[:db]
  end

  def current_db
    MongoFe::MongoDB.connection.db(session[:db]) if current_db?
  end

  def current_db_name
    session[:db] if current_db?
  end

  def collection
    current_db.collection(session[:collection]) if current_db? && collection?
  end

  def collection?
    true if session[:collection]
  end

  def link_to(name, location, alternative = false)
    if alternative && alternative[:condition]
      "<a href=#{alternative[:location]}>#{alternative[:name]}</a>"
    else
      "<a href=#{location}>#{name}</a>"
    end
  end

  # prettifying a JSON structure
  def pretty_json(json)
    JSON.pretty_generate(json)
  end

  # truncate a string to max characters and append '...' at the end
  def truncate(str, max=0)
    return '' if str.blank?

    if str.length <= 1
      t_string = str
    else
      t_string = str[0..[str.length, max].min]
      t_string = str.length > t_string.length ? "#{t_string}..." : t_string
    end

    t_string
  end

  # poor man flash solution
  def flash
    session[:flash] = Hashie::Mash.new if session[:flash].nil?
    session[:flash]
  end

  PLACEHOLDER_SORT = "ex. name:ASC, age:DESC"
  PLACEHOLDER_QUERY_STRING = 'ex. {"name":"foo"}'
  PLACEHOLDER_SHOW = "ex. name, age"

  # check if there is a query in the session and return its elements as an openstruct object
  def query
    if (q = session[:query])
      OpenStruct.new(:string => q.first.empty? ? '' : q.first.to_json,
                     :show => q[1].empty? ? '' : q[1],
                     :sort => q.last.empty? ? '' : q.last)
    else
      OpenStruct.new(:string => PLACEHOLDER_QUERY_STRING, :show => PLACEHOLDER_SHOW, :sort => PLACEHOLDER_SORT)
    end
  end

  # stolen from http://github.com/cschneid/irclogger/blob/master/lib/partials.rb
  # and made a lot more robust by me: https://gist.github.com/119874.
  # Another me, not me :)
  def partial(template, *args)
    template_array = template.to_s.split('/')
    template = template_array[0..-2].join('/') + "/_#{template_array[-1]}"
    options = args.last.is_a?(Hash) ? args.pop : {}
    options.merge!(:layout => false)
    locals = options[:locals] || {}

    if (collection = options.delete(:collection))
      collection.inject([]) do |buffer, member|
        buffer << haml(:"#{template}",
                       options.merge(:layout => false,
                                     :locals => {template_array[-1].to_sym => member}.merge(locals)))
      end.join("\n")
    else
      haml(:"#{template}", options)
    end
  end

  # generate a simple random string
  def random_string(len)
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    str = ""
    1.upto(len) { |i| str << chars[rand(chars.size-1)] }
    str
  end


  MEGABYTE = 1024.0 * 1024.0

  # convert Bytes to MegaBytes
  def bytes_to_mb bytes=0
    bytes / MEGABYTE
  end

end