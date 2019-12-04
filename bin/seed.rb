# this calls api_communicator to seed the db with a onetime call to MLB API

require_relative "../config/environment.rb"

player_data_hashes = add_stats_to_player_hashes(get_players(get_teams))


player_data_hashes.each do |player|
  Player.create(player)
end 

binding.pry 
# push players to db
# gets hitting stats for all players
# push hitting stats to db
