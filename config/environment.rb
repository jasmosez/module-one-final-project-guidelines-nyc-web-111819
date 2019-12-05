require 'bundler'
Bundler.require

PROMPT = TTY::Prompt.new
POSITION_HASH = {
    "Pitcher" => "P",
    "Catcher" => "C",
    "First Base" => "1B",
    "Second Base" => "2B",
    "Third Base" => "3B",
    "Shortstop" => "SS",
    "Left Field" => "LF",
    "Center Field" => "CF",
    "Right Field" => "RF",
    "Designated Hitter" => "DH",
    "Utility Outfielder" => "OF"
  }

POSITION_BLOCKS = {
    :outfielders => ["LF", "CF", "RF", "OF"],
    :infielders => ["1B", "2B", "3B", "SS"],
    :pitchers => ["P"],
    :catchers => ["C"],
    :designated_hitters => ["DH"]
  }




ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: 'db/development.db')
require_all 'models'
require_all 'lib'

ActiveRecord::Base.logger = nil