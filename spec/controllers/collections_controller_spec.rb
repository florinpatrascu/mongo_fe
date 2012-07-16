require "spec_helper"
require "ostruct"
require "json"

describe "Collections Controller" do
  class Index
    attr_accessor :name
    attr_reader :fields

    def initialize(fields="", unique=true, sparse=false)
      @fields=fields
      @unique=unique
      @sparse=sparse
    end

    def unique?
      @unique
    end

    def sparse?
      @sparse
    end
  end

  let(:db_name) { "mongo_fe_test_db_collections_29837419283741928374192834719283" }
  let(:collection_name) { "my_mongo_fe_collection" }
  let(:collection_new_name) { "my_new_mongo_fe_collection" }

  # use Time.new.strftime("%d-%m-%Y")? meh
  let(:test_doc) { {:lng => "gr", :description => "Hopa!", :created_at => Time.now.to_i} }
  let(:test_doc_json) { test_doc.to_json }

  let(:index) { Index.new("lng:asc, created_at:desc") }

  # select/create a test database 
  before(:all) do
    get "/databases/#{db_name}"
  end

  # clean the test database.
  after(:all) do
    delete "/databases/#{db_name}"
  end

  # Adding a new collection to a test database
  describe "POST /databases/:db_name/collections/" do
    it "should create a new collection" do
      post "/databases/#{db_name}/collections", {:collection_name => collection_name}
      follow_redirect!
      last_response.body.should contain("#{collection_name}, successfully created!")
    end
  end

  # return success if a database is selected and we want to display the available
  #  collections
  describe "GET /databases/:db_name/collections" do
    #,{}, "rack.session" => {:session => {:db => "test"} } .... meh
    it "should list all the collections available" do
      get "/databases/#{db_name}/collections"
      last_response.status.should eq(200)
      last_response.body.should contain("#{collection_name}")
    end
  end

  describe "GET /databases/:db_name/collections/:collection_name" do
    it "should display the stats for the given collection" do
      get "/databases/#{db_name}/collections/#{collection_name}"
      last_response.body.should contain("\"ns\": \"#{db_name}.#{collection_name}\"")
    end
  end

  describe "PUT /databases/:db_name/collections/:collection_name" do
    it "should rename a collection" do
      put "/databases/#{db_name}/collections/#{collection_name}", {:collection_new_name => collection_new_name}
      follow_redirect!
      last_response.body.should_not contain("\"ns\": \"#{db_name}.#{collection_name}\"")
      last_response.body.should contain("\"ns\": \"#{db_name}.#{collection_new_name}\"")
    end
  end

  describe "POST /databases/:db_name/collections/:collection_name/documents" do
    it "should insert a new document" do
      post "/databases/#{db_name}/collections/#{collection_name}/documents", {:json_doc_attributes => test_doc_json}
      last_response.body.should contain("added to: #{db_name}.#{collection_name}")
      # todo verify the Document insertion
    end
  end

  describe "DELETE /databases/:db_name/collections/:collection_name/documents" do
    it "should delete an existing document" do

      db = MongoFe::MongoDB.use db_name
      db.should_not be_nil

      c = db.collection(collection_name)
      c.should_not be_nil

      doc = c.find_one test_doc
      doc.should_not be_nil

      doc_id=doc['_id'].to_s
      delete "/databases/#{db_name}/collections/#{collection_name}/documents", {:doc_id => doc_id}
      follow_redirect!
      last_response.body.should contain("deleted from: #{db_name}.#{collection_name}")
    end
  end

  describe "POST /databases/:db_name/collections/:collection_name/indexes" do
    it "should create a new index" do
      post "/databases/#{db_name}/collections/#{collection_name}/indexes",
           {:index_fields => index.fields, :index_unique => index.unique?, :sparse => index.sparse?}

      follow_redirect!
      # "The index: '#{index_name}' was successfully created"
      index.name = last_response.body[/index: '([^']+)/,1]
      last_response.body.should contain("was successfully created")
    end
  end

  # Drop a collection index
  describe "DELETE /databases/:db_name/collections/:collection_name/indexes" do
    it "should delete an existing index" do
      db = MongoFe::MongoDB.use db_name
      db.should_not be_nil

      collection = db.collection(collection_name)
      collection.name.should_not be_nil

      indexes = collection.index_information
      indexes.should contain(index.name)

      delete "/databases/#{db_name}/collections/#{collection_name}/indexes", {:index_name => index.name}
      follow_redirect!
      last_response.body.should contain("The index: '#{index.name}', was deleted successfully.")

      indexes = collection.index_information
      indexes.should_not contain(index.name)      
    end
  end

  # Delete a collection from a test database
  describe "DELETE /databases/:db_name/collections/:collection_name" do
    it "should delete a collection" do
      delete "/databases/#{db_name}/collections/#{collection_name}"
      # , {:collection_name => collection_name}
      follow_redirect!
      last_response.body.should contain("#{collection_name}, deleted.")
    end
  end

end