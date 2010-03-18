require 'rubygems'
require 'sinatra'

set(:run, false)
set(:env, 'production')
set(:root, File.dirame(__FILE__))

run Sinatra::Application

log = File.new("log/sinatra.log", "a+")
$stdout.reopen(log)
$stderr.reopen(log)