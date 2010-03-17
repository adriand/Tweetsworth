require 'rubygems'
require 'sinatra'

Sinatra::Base.set(:run, false)
Sinatra::Base.set(:env, ENV['RACK_ENV'])

require 'toopaste'
run Sinatra.application
