require 'rubygems'
require 'bundler'
require 'open-uri'
require 'base64'

Bundler.require

require './app'
run Sinatra::Application