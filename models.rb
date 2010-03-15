# http://httparty.rubyforge.org/
# E.g.: Twitter.get('/1/users/show.json', :query => { :screen_name => "USERNAME" })
class Twitter
  include HTTParty
  base_uri 'api.twitter.com'
end

class Username
  include DataMapper::Resource
  
  property :id, Serial
  property :name, String
  # storing the created_at timestamp will help us track site participation
  # in order to have this set for us automatically, we've added:
  # require 'dm-timestamps'
  # to the list of required gems.
  property :created_at, DateTime
   
end