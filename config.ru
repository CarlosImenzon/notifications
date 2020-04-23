require "bundler"
require "sinatra"
require 'sequel'


Bundler.require
DB = Sequel.connect(
  adapter: 'postgres',
  database: 'notificator-development',
  host: 'db',
  user: 'unicorn',
  password: 'magic')

require "./app.rb"
run App
