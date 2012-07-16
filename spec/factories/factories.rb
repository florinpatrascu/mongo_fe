FactoryGirl.define do
  # user.rb
  class User
    attr_accessor :username, :email, :password, :readonly, :created_at
  end
  
  sequence :email do |n|
    "user#{n}@example.com"
  end
  
  factory :user do
    username  "alphaville"     
    email
    password  "password"
    readonly  true
    # created_at { rand(10).days.ago }
  end

end
