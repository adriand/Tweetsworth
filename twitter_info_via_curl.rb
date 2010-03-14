require 'rubygems'
require 'ruby-debug'

abort("Supply a twitter screen name like: ruby twitter_info_via_curl.rb tomcreighton") unless ARGV.size > 0

# the -s argument makes curl silent (it will no longer show a progress meter)
# don't forget to append m to your regular expressions if you want the . to match newline characters
user_info = `curl -s http://api.twitter.com/1/users/show.xml?screen_name=#{ARGV[0]}`.match(
  /<followers_count>(\d*)<\/followers_count>.*<statuses_count>(\d*)<\/statuses_count>/m)
puts "Followers: #{user_info[1]}"
puts "Statuses: #{user_info[2]}"