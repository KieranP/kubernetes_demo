require 'rubygems'
require 'bundler'

Bundler.require

require 'sinatra'
require 'sinatra/base'
require 'sinatra/reloader'

require_relative 'app'
run Application
