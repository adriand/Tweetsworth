# When we create our Rackup file, we'll already be requiring RubyGems and Sinatra, 
# so we don't require them again if they've already been loaded.
require 'rubygems' unless defined? ::RubyGems
require 'sinatra' unless defined? ::Sinatra
require 'rack' # more on the decision to include this below
require 'dm-core'
require 'dm-timestamps'
require 'haml'
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
  # Put your production database connection string here.
  
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
# DataMapper.auto_migrate!

get '/' do
  haml :index
end

get '/style.css' do
  response['Content-Type'] = 'text/css; charset=utf-8'
  sass :style
end

post '/value' do
  username = params[:username]
  if username && username != ""
    @info = Twitter.get('/1/users/show.json', :query => { :screen_name => username })
    if @info['error']
      redirect "/?failure=There was an error retrieving your account information. Twitter says: #{info['error']}."
    else
      haml :index
    end
  else
    redirect "/?failure=Please enter a Twitter username to start the valuation process."
  end
end

helpers do
  
end