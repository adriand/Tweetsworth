# When we create our Rackup file, we'll already be requiring RubyGems and Sinatra, 
# use 'unless defined?' so we don't require the gems again if they've already been loaded.
require 'rubygems' unless defined? ::RubyGems
require 'sinatra' unless defined? ::Sinatra
require 'rack' # more on the decision to include this below
require 'dm-core'
require 'dm-timestamps'
require 'haml'
require 'sass'
require 'httparty'
require 'ruby-debug'

# If you want changes to your application to appear in development mode without having to 
# restart the application, you need something that will reload your app automatically. 
# There are solutions out there (like Shotgun) but these are very slow. It's far quicker 
# to use this method to reload your app. However, it's not foolproof: sometimes, things
# will get screwy. When that happens, just restart your application manually.
configure :development do
  Sinatra::Application.reset!
  use Rack::Reloader

  DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/db/tweetsworth.sqlite3")  
end

configure :production do
  require '/var/apps/tweetsworth/shared/config/production.rb'
end

# This is such a simple application that we likely don't need a separate file for models, 
# but it keeps things clean.
require 'models'

# DataMapper's automatic upgrading is not without its issues, which is not that surprising
# given what it attempts to do. Don't rely on it to always do what you expect - use
# auto_migrate! to ensure your database schema is updated correct. HOWEVER, note that 
# auto_migrate! will destroy the data in your database, so you should never use it in a 
# production environment (this may be a surprise to Rails users).  I tend to use auto_migrate! 
# as I build the app and make major db changes, but once I have things pretty stable
# I switch to auto_upgrade!.
DataMapper.auto_upgrade!
#DataMapper.auto_migrate!

get '/' do
  @recent = Person.all(:limit => 5, :order => [ :created_at.desc ])
  @top = Person.all(:limit => 5, :order => [ :followers_count.desc ])
  haml :index
end

get '/style.css' do
  response['Content-Type'] = 'text/css; charset=utf-8'
  sass :style
end

post '/value' do
  screen_name = params[:screen_name]
  if screen_name && screen_name != ""
    @info = Twitter.get('/1/users/show.json', :query => { :screen_name => screen_name })
    if @info['error']
      redirect "/?failure=There was an error retrieving your account information. Twitter says: #{info['error']}."
    else
      # Since we've now successfully retrieved information on a user account, we'll either look up or save this user in our
      # database.
      person = Person.first(:screen_name => screen_name)
      unless person
        person = Person.new(
          :screen_name => screen_name, 
          :name => @info['name'], 
          :joined_twitter_at => DateTime.parse(@info['created_at'])
        )
      end
      # These attributes can change over time
      person.followers_count, person.statuses_count, person.profile_image_url = @info['followers_count'], @info['statuses_count'], @info['profile_image_url']
      person.save
      redirect "/w/#{person.screen_name}"
    end    
  else
    redirect "/?failure=Please enter a Twitter username to start the valuation process."
  end
end

# The shorter the url, the better for Twitter
get '/w/:screen_name' do
  @person = Person.first(:screen_name => params[:screen_name])
  @page_title = @person.name
  @js = erb :person_js
  haml :person
end

not_found do
  haml :'404'
end

helpers do  
  def twitter_link(person)
    "<a href='http://twitter.com/#{person.screen_name}' target='_'>#{person.name}</a>"
  end
  
  def tweet_insult(tweets)
    case tweets
      when 0..400 then ["Don't have much to say? No big surprise there."]
      when 401..10000 then ["You sure like the sound of your own voice.", "Just what the web needs: another narcissist."]
      else ["The volume of your tweets is only matched by their stupidity."]
    end.sort_by { rand }.first
  end
  
  def follower_insult(followers)
    case followers
      when 0..100 then ["Hopefully you've got more friends offline, though we're not counting on it."]
      when 101..1000 then ["That's like, what, a small village? A hamlet? Way to escape the farmstead, chief.", "And you thought you'd get more popular once you finished high school."]
      else ["Proof positive that large numbers of people can be very, very wrong.", "Lemmings."]
    end.sort_by { rand }.first
  end
  
  def duration_insult(joined_twitter_at)
    case (Date.today - joined_twitter_at)
      when 0..120 then ["A little late to the party, no?"]
      else ["Words thrown into a void, my friend. Sad, really.", "Normally people get better at something the longer they do it."]
    end.sort_by { rand }.first
  end
  
  def retweet_insult
    ["Your retweets are so boring our algorithm fell asleep.", "Take the hint: nobody cares what you have to say."].sort_by { rand }.first
  end
  
end

private

  def progress_statements
    [
      ["Evaluating Followers", "Questionable"],
      ["Analyzing Retweet Recursion Depth", "Substantial"],
      ["Syntax, Grammar and Vocabulary Analysis", "Seventh grade"],      
      ["Determining Mediated Collective Influence", "Fourth degree"],
      ["Resolving Social Matrix Lattices", "Semi-entwined"],
      ["Reticulating Splines", "Bezier"]
    ]
  end