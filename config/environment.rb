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

ASCII = (
puts ""
puts ""
puts ""
puts ""

puts '       d8888 888 888  .d8888b. 88888888888                        888888b.                              888               888 888'.colorize(:red)
puts '      d88888 888 888 d88P  Y88b    888                            888  "88b                             888               888 888'.colorize(:red)
puts '     d88P888 888 888 Y88b.         888                            888  .88P                             888               888 888'.colorize(:red)
puts '    d88P 888 888 888  "Y888b.      888   8888b.  888d888 88888888 8888888K.   8888b.  .d8888b   .d88b.  88888b.   8888b.  888 888'.colorize(:white)
puts '   d88P  888 888 888     "Y88b.    888      "88b 888P"      d88P  888  "Y88b     "88b 88K      d8P  Y8b 888 "88b     "88b 888 888'.colorize(:white)
puts '  d88P   888 888 888       "888    888  .d888888 888       d88P   888    888 .d888888 "Y8888b. 88888888 888  888 .d888888 888 888'.colorize(:white)
puts ' d8888888888 888 888 Y88b  d88P    888  888  888 888      d88P    888   d88P 888  888      X88 Y8b.     888 d88P 888  888 888 888'.colorize(:blue)
puts 'd88P     888 888 888  "Y8888P"     888  "Y888888 888     88888888 8888888P"  "Y888888  88888P"  "Y8888  88888P"  "Y888888 888 888'.colorize(:blue)
                                                                                                                            
puts ""
puts ""
puts ""
puts "")                           



ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: 'db/development.db')
require_all 'models'
require_all 'lib'

ActiveRecord::Base.logger = nil