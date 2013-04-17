require 'rubygems'
require 'bundler'
require 'open-uri'

Bundler.require

require './app'
run Sinatra::Application