require 'rake'
require 'active_record'
require 'rest-client'
require 'json'
require 'pry'

require 'bundler'
Bundler.require

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: 'db/development.db')
require_all 'lib'
