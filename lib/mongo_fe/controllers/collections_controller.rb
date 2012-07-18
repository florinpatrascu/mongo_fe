# encoding: utf-8
require "json"
require File.dirname(__FILE__) + '/../application_controller'
require 'will_paginate'
require 'will_paginate/view_helpers/sinatra'
require "will_paginate/bootstrap"

module MongoFe
  # This controller works as a collection manager for the current db, a database specified by
  # name as a REST parameter.

  class CollectionsController < ApplicationController
    namespace '/databases/:db_name/collections' do

      before do
        session[:db]=params[:db_name]
      end

      get "/?" do
        haml :'/collections/index'
      end

      get "/:collection_name/?" do

        collection_name = params[:collection_name]

        unless collection_name.nil?
          session[:collection] = collection_name
          @collection = current_db.collection collection_name
          @indexes = @collection.index_information
          @page = params[:page].to_i || 1
          @query= session[:query]

          begin
            @total, @documents = MongoFe::MongoDB::SearchDocuments.new(current_db, @collection).list(@query, @page, 10)
            flash_search_results @query, @total
          rescue => e
            session[:query] = nil
            @total, @documents = MongoFe::MongoDB::SearchDocuments.new(current_db, @collection).list(nil, 1, 10)

            flash[:error] = "Resetting to find all. MongoDB error: #{e.message}"
          end

        end

        haml :'/collections/index'
      end

      post "/?" do
        if (collection_name=params[:collection_name])
          current_db.create_collection(collection_name)
          flash[:notice] = "#{collection_name}, successfully created!"
          redirect "/databases/#{current_db.name}/collections/#{collection_name}"
        else
          flash[:error] = "Error: you must provide a collection name."
          redirect "/databases/#{current_db.name}"
        end
      end

      post "/:collection_name/search/?" do |db_name, collection_name|

        if params[:reset_query].nil?
          json_query = params[:json_query].empty? ? '{}' : params[:json_query].gsub(/'/, "\"")
          json_query_show = params[:json_query_show]
          json_query_sort = params[:json_query_sort]

          begin
            @json_query = JSON.parse json_query
            puts "{query}: #{@json_query.inspect}"
            session[:query] = [@json_query, json_query_show, json_query_sort]
          rescue => e
            flash[:error] = "Invalid query; #{e.message}"
          end
        else
          session[:query] = nil
        end

        redirect "/databases/#{current_db.name}/collections/#{collection_name}"
      end

      delete "/:collection_name/documents*" do |db_name, collection_name, doc_id|
        if (doc_id = params[:doc_id])
          begin
            collection = current_db.collection collection_name
            collection.remove(:_id => BSON::ObjectId.from_string(doc_id))
            flash[:notice] = "Document id: #{doc_id}, deleted from: #{db_name}.#{collection.name}"
          rescue => e
            flash[:error] = "Cannot delete document id: #{doc_id}, from: #{db_name}.#{collection_name}; #{e.message}"
          end
        else
          flash[:error] = "The document id must be specified"
        end

        redirect "/databases/#{current_db.name}/collections/#{collection_name}"
      end

      put "/:collection_name/documents*" do |db_name, collection_name, z|
        if (doc_id = params[:doc_id])
          begin
            @collection = current_db.collection collection_name
            id = BSON::ObjectId.from_string(doc_id)
            r = @collection.find(:_id => id).to_a
            raise "this document is missing!" if r.nil?

            begin
              if (doc=params[:json_doc_attributes])
                begin
                  @doc_id = collection.update({"_id" => id}, JSON.parse(doc)) # rewrite the doc; in the future will use an atomic operator
                  flash[:notice] = "Document id: #{doc_id}, updated"
                rescue => e
                  raise "Invalid JSON structure: #{e.message}"
                end
              else
                raise "Invalid document."
              end
            rescue => e
              flash[:error] = "Cannot update document; #{e.message}"
            end

          rescue => e
            flash[:error] = "Cannot update the document with id: #{doc_id}; #{e.message}"
          end
        else
          flash[:error] = "The document id must be specified"
        end

        redirect "/databases/#{current_db.name}/collections/#{collection_name}"
      end

      # create a new index
      post "/:collection_name/indexes*" do |db_name, collection_name, z|
        @collection = current_db.collection collection_name
        session[:collection] = @collection.name

        unique = !params[:unique].nil? && params[:unique]
        sparse = !params[:sparse].nil? && params[:sparse]

        if (fields = params[:index_fields])
          begin
            index_name = @collection.create_index(MongoFe::Utils.split_index_specs(fields), {:unique => unique, :sparse => sparse})

            flash[:notice]="The index: '#{index_name}' was successfully created"
          rescue => e
            flash[:error]="Cannot create the index; #{e.message}"
          end
        else
          flash[:error]="Specify either a single field name or an array of field name, direction pairs"
        end

        redirect "/databases/#{current_db.name}/collections/#{collection_name}"
      end


      # delete an existing index
      #
      delete "/:collection_name/indexes*" do |db_name, collection_name, z|
        @collection = current_db.collection collection_name

        if (index_name = params[:index_name])
          begin
            @collection.drop_index index_name
            flash[:notice] = "The index: '#{index_name}', was deleted successfully."
          rescue => e
            flash[:error] = "The index: '#{index_name}', cannot be deleted; #{e.message}"
          end

        else
          flash[:error] = "Please specify the index name."
        end

        session[:collection] = @collection.name
        redirect "/databases/#{current_db.name}/collections/#{collection_name}"
      end


      # create a new document
      #
      post "/:collection_name/documents*" do
        @collection = current_db.collection(params[:collection_name])

        if @collection.nil?
          flash[:error] = "Error: you must provide a valid collection name."
          redirect "/databases/#{current_db.name}"
        else
          session[:collection] = @collection.name # move this and the one above to a before or such

          begin
            if (doc=params[:json_doc_attributes])
              begin
                @doc_id = @collection.insert(JSON.parse(doc))
                flash[:notice] = "Document id: #{@doc_id.to_s}, added to: #{current_db.name}.#{@collection.name}"
              rescue => e
                raise "Invalid JSON structure; #{e.message}"
              end
            else
              raise "Invalid document."
            end
          rescue => e
            flash[:error] = "Cannot insert document; error: #{e.message}"
          end

        end

        redirect "/databases/#{current_db.name}/collections/#{@collection.name}"
      end

      put "/:collection_name/?" do
        if (collection_name=params[:collection_name])
          collection = current_db.collection(collection_name)

          if collection.nil?
            flash[:error] = "The db: #{current_db.name} doesn't know this collection: #{collection_name}"
          else
            if (collection_new_name = params[:collection_new_name])

              begin
                current_db.rename_collection(collection_name, collection_new_name)
                flash[:notice] = "Collection: #{collection_name}, successfully renamed to: #{collection_new_name}"
                redirect "/databases/#{current_db.name}/collections/#{collection_new_name}"
              rescue => e
                flash[:error] = "Cannot rename: #{collection_name}, to: #{collection_new_name}; error: #{e.message}"
              end

            else
              flash[:error] = "You must provide a collection name."
            end
            redirect "/databases/#{current_db.name}/collections/#{collection_name}"
          end

        else
          flash[:error] = "Error: you must provide a collection name."
          redirect "/databases/#{current_db.name}"
        end
      end

      delete "/:collection_name/?" do
        db=current_db
        if (collection_name=params[:collection_name])
          if (collection = db.collection(collection_name))
            begin
              collection.drop
              flash[:notice] = "#{collection_name}, deleted."
            rescue => e
              flash[:error] = "Error: #{e.message}, while trying to delete the collection: #{collection_name}"
            end
          end
        else
          flash[:error] = "Error: you must provide a collection name."
        end

        redirect "/databases/#{db.name}"
      end

    end

    private
    def flash_search_results(q, total)
      flash[:notice]="query: #{query.string}<br/>#{total} document(s) found." unless (q.nil? || query.string.start_with?("ex."))
    end
  end

end
