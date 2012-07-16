require 'spec_helper'

describe "MongoFe" do
  describe "the gem configuration" do    
    it "is versioned" do
      MongoFe::VERSION.should =~ /\d+\.\d+\.\d+/
    end
    
    it "has access to a local database" do
      MongoFe::MongoDB.connection.should_not be_nil
    end
    
    it "can access some data" do
      MongoFe::MongoDB.available_databases.count.should >= 0
    end
  end
end
