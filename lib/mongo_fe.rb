# encoding=utf-8

require File.dirname(__FILE__) + '/mongo_fe/version'
require "mongo" # API: http://api.mongodb.org/ruby/1.6.4/
require "uri"

module MongoFe

  module MongoDB
    @@user_db = nil

    # simple proxy to Mongo::DB
    class Database
      instance_methods.each { |m| undef_method m unless m =~ /(^__|^send$|^object_id$)/ }

      def initialize(db)
        @db=db
      end

      def users
        if db_users = @db[Mongo::DB::SYSTEM_USER_COLLECTION]
          db_users.find.to_a
        end
      end

      def find_user(username=nil)
        if db_users = @db[Mongo::DB::SYSTEM_USER_COLLECTION]
          db_users.find_one({:user => username}) unless username.nil?
        end
      end

      # todo: Add more convenient methods

      protected
      def method_missing(name, *args, &block)
        @db.send(name, *args, &block)
      end
    end

    class SearchDocuments
      def initialize(a_db, a_collection)
        @db=a_db
        @collection=a_collection
      end

      def list(user_query, page=1, per_page=10)
        page_nr = page > 0 ? page : 1
        query   = user_query.nil? ? [{}, [], []] : user_query

        q = query.first.dup

        # verify if we have query containing a regexp
        q.each_pair do |k, v|
          if v.is_a?(String) && v.index(/^\//)
            q[k] = Regexp.new(v.gsub("/", ''))
          end
        end

        # quickly find the total hits
        count = @db.collection(@collection.name).find(q).count

        # get the docs and paginate.
        documents_list = WillPaginate::Collection.create(page_nr, per_page, count) do |pager|
          results = @collection.find( q,
                                      :sort => sort_by(query.last),
                                      :skip => ((page_nr-1) * per_page).to_i,
                                      :limit => per_page,
                                      :fields => just_these_fields(query[1])
                                    ).to_a
          pager.replace(results)
        end

        [count, documents_list]
      end

      private #---------------- private stuff

      # @param [String] criteria_string
      def sort_by(criteria_string)
        criteria_string.empty? ? [['_id', Mongo::DESCENDING]] : MongoFe::Utils.split_index_specs(criteria_string)
      end

      # Retrieving a Subset of Fields info here: http://bit.ly/P2ZLiV
      def just_these_fields(fields_string)
        fields = nil #all

        unless fields_string.nil?
          fields_string = fields_string.delete(' ')
          unless fields_string.nil?
            fields = []
            fields_string.split(/[\s,]+/).each do |f|
              fields << f.to_sym unless f.nil?
            end
          end
        end

        fields
      end
    end

    def self.use(db_name=nil)
      if !@@user_db.nil? && db_name != @@user_db
        raise 'Invalid database name. Not authorized, maybe?!'
      end
      
      Database.new(self.connection.db(db_name))
    end

    def self.uri
      @@uri = nil unless defined?(@@uri) 
      @@uri
    end
    
    def self.uri=(uri)
      begin
        @@uri  = URI.parse(uri)
        @@host = @@uri.host
        @@port = @@uri.port        
      rescue => e
        raise "#{e.message}; #{uri}"
      end      
    end
    
    def self.connection
      begin
        unless defined?(@@connection)
          uri = @@uri.to_s
          @@connection = Mongo::Connection.from_uri(uri) 
          if @@uri.user && @@uri.password
            if !@@uri.path.nil?
              @@user_db = @@uri.path.gsub(/^\//, '')
              @@connection.add_auth(@@user_db, @@uri.user, @@uri.password)
            else
              raise "username and password provided but the db name is missing. Please verify the config uri."
            end
          end
        end
      
        @@connection
      rescue Mongo::ConnectionFailure => e
        raise "Please verify that you have a MongoDB started at: #{@@host}:#{@@port} error: #{e.message}"
      end
    end
    
    def self.available_databases
      if @@user_db
        [@@user_db]
      else
        self.connection.database_names - %w[admin local slave]
      end
    end
  end

  class Utils

    def self.split_index_specs(fields=nil)
      specs = []

      unless fields.empty?
        fields.delete(' ').split(/[\s,]+/).each do |s|
          f= s.split(/[\s:]+/)
          specs << [f[0].to_sym, f[1].downcase.start_with?('asc') ? Mongo::ASCENDING : Mongo::DESCENDING]
        end
      end

      specs
    end
  end

end
