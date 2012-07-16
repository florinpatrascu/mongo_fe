require 'spec_helper'

describe "Databases Controller" do
  # careful not to overwrite any existing db; todo: improve the naming solution
  let(:db_name) { "mongo_fe_test_db_01293801983479827349832987234987234987" }
  let(:new_db_name) { "mongo_fe_test_db_012938019747473873563872ABHEYYO827PI12" }
  
  describe "GET /databases" do
    it "should return success" do
      get '/databases'
      last_response.body.should contain("Move along, nothing to see here!")
    end
  end

  describe "POST /databases" do
    context "when a new database is successfully created" do
      before(:all) do
        post '/databases', {:name => db_name}        
      end

      it "returns a 302 response code" do
        last_response.status.should eq(302)
      end

      it "should create a new database" do
        get "/databases/#{db_name}"
        last_response.body.should contain("#{db_name}")
      end

    end
  end

  describe "GET /databases/:name" do
    it "should return info about the newly created database" do
      get "/databases/#{db_name}"
      last_response.body.should contain("\"db\": \"#{db_name}\",")
    end
  end

  # test the user creation
  describe "POST /databases/:name/users" do
    let(:test_user) { FactoryGirl.build(:user) }
    it "should create a new user" do
      post "/databases/#{db_name}/users", {:username => test_user.username,
                                           :password => test_user.password, :readonly => test_user.readonly}
      follow_redirect!
      last_response.body.should contain("User: '#{test_user.username}', was added successfully.")
      # or better:
      # flash[:notice].should =~ /User: '#{test_user.username}', was added successfully./
    end
  end

  # test the user deletion
  describe "DELETE /databases/:name/users" do
    let(:test_user) { FactoryGirl.build(:user) }
    it "should delete a user" do
      delete "/databases/#{db_name}/users", {:username => test_user.username}
      follow_redirect!
      last_response.body.should contain("User deleted: '#{test_user.username}'")
    end
  end

  describe "DELETE /databases/:name" do
    it "should delete a database" do
      delete "/databases/#{db_name}"
      last_response.body.should contain("Database: #{db_name} was deleted.")
    end
  end
end