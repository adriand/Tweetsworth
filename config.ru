require 'rubygems'
require 'sinatra'

Sinatra::Base.set(:run, false)
Sinatra::Base.set(:env, 'production')

run Sinatra::Application

log = File.new("log/sinatra.log", "a+")
$stdout.reopen(log)
$stderr.reopen(log)