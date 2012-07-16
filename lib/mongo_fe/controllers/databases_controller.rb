# encoding: utf-8
require "mongo"
require File.dirname(__FILE__) + '/../application_controller'

module MongoFe
  class DatabasesController < ApplicationController
    
    get '/databases/?' do
      "Move along, nothing to see here!"
    end

    # info about a specific database
    get '/databases/:name/?' do      
      db_name = params[:name]
      begin          
        @db = MongoFe::MongoDB.use(db_name)
        session[:db] = db_name
        session[:collection] = nil
        # flash[:notice] = "DB Selected: #{db_name}. <a href='/databases/#{db_name}/info'>More info?</a>"
        haml :'/databases/info'
      rescue => e
        session[:db]=nil
        flash[:error] = "You must provide a database name; #{e.message}"
        redirect "/"
      end
    end

    # create a new database
    post '/databases/?' do
      if (d=params[:name])
        db = MongoFe::MongoDB.use(d)
        session[:db]=d
        flash[:notice] = "A new database: `#{d}`, was created."
        redirect "/databases/#{d}"
      else
        flash[:error] = "Error: you must provide a database name."
        haml :index
      end
    end

    # Delete database
    delete '/databases/:name/?' do |d|
      if d
        begin
          MongoFe::MongoDB.connection.drop_database(d)
          flash[:notice] = "Database: #{d} was deleted."
          session[:db]=nil
        rescue => e
          flash[:error] = "Error: #{e.message }; The database: `#{d}` was not deleted."
        end
      else
        flash[:notice] = "Error: you must provide a database name."
      end
      haml :index
    end

    # create a new database user
    post '/databases/:name/users/?' do |d|
      if d && username=params[:username]
        db = MongoFe::MongoDB.use(d)
        if db.find_user(username)
          flash[:error] = "the user: '#{username}' is already defined."
        else
          is_readonly = params[:readonly].nil? ? false : true
          db.add_user(username, params[:password], is_readonly)
          flash[:notice] = "User: '#{username}', was added successfully."
        end
      else
        flash[:error] = "you must provide a user name."
      end

      redirect "/databases/#{d}"
    end

    # delete an exiting user
    delete '/databases/:name/users/?' do |d|
      if d && username=params[:username]
        db = MongoFe::MongoDB.use(d)
        if db.find_user(username)
          db.remove_user(username)
          flash[:notice] = "User deleted: '#{username}'"
        else
          flash[:error] = "Not a valid username: '#{username}'"
        end
      else
        flash[:error] = "Please provide a user name."
      end

      redirect "/databases/#{d}"      
    end

  end
end

