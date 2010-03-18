# http://httparty.rubyforge.org/
# E.g.: Twitter.get('/1/users/show.json', :query => { :screen_name => "USERNAME" })
class Twitter
  include HTTParty
  base_uri 'api.twitter.com'
end

# sure, 'class Tweep' would work too, but no way in hell are we going down that road.
class Person
  include DataMapper::Resource
  
  property :id, Serial
  property :screen_name, String, :unique_index => true
  property :name, String
  property :profile_image_url, Text
  # storing these will allow us to rank this person against other users
  # if we wish, we can also use these as cached results from Twitter if the user
  # returns to the site within a certain amount of time
  property :followers_count, Integer
  property :statuses_count, Integer
  property :joined_twitter_at, DateTime
  # storing the created_at timestamp will help us track site participation
  # in order to have this set for us automatically, we've added:
  # require 'dm-timestamps'
  # to the list of required gems.
  property :created_at, DateTime
  
end