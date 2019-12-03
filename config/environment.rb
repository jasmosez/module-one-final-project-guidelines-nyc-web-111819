require 'bundler'
Bundler.require

PROMPT = TTY::Prompt.new

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: 'db/development.db')
require_all 'models'
require_all 'lib'
