require 'rubygems'
require 'sinatra'

set(:run, false)
set(:env, 'production')
set :root, '/'

run Sinatra::Application

log = File.new("log/sinatra.log", "a+")
$stdout.reopen(log)
$stderr.reopen(log)