# require_relative '../config/environment.rb'
require 'rest-client'
require 'json'

def get_teams
  # returns an array of MLB Team ID's (as per MLB API)
  
  # get teams by season (2019) 
  # In this instance, we are hard coding 2019.
  # Could parse for interporlation, in the future 
  url = "http://lookup-service-prod.mlb.com/json/named.team_all_season.bam?sport_code='mlb'&all_star_sw='N'&sort_order=name_asc&season='2019'"
  response_string = RestClient.get(url)
  response_hash = JSON.parse(response_string)
  
  # parse to an array of team ids
  team_ids = response_hash["team_all_season"]["queryResults"]["row"].map do |team|
    team["team_id"]
  end
end

def get_players(team_ids)
  binding.pry
  # Call team rosters. Return array of players

  url = "http://lookup-service-prod.mlb.com/json/named.roster_40.bam?team_id="
  player_data_hashes = []
  
  team_ids.each do |id| 
    response_string = RestClient.get(url + id)
    response_hash = JSON.parse(response_string)

    # iterate over team_ids. push to player_ids  
    response_hash["roster_40"]["queryResults"]["row"].each do |player|
      player_data_hashes << {
        mlb_player_id: player["player_id"],
        name: player["name_display_first_last"],
        position: player["position_txt"],
        team: player["team_name"]
    }
    end
  end
  
  # be sure to return player_ids 
  binding.pry
  player_data_hashes
end



def add_stats_to_player_hashes(player_data_hashes)
  binding.pry
  # get season hitting stats data by player id. Return as a hash, ready to store in db
  #takes in an array of hashes not player objects
  # In this instance, we are hard coding 2019. Could parse for interporlation, in the future 
  url = "http://lookup-service-prod.mlb.com/json/named.sport_hitting_tm.bam?league_list_id='mlb'&game_type='R'&season='2019'&player_id="
  
  counter = 0

  player_data_hashes.each do |player|
    counter +=1
    response_string = RestClient.get(url + player[:mlb_player_id])
    response_hash = JSON.parse(response_string)
    # binding.pry 
    # handling for when player has no hitting stats
    
    result = response_hash["sport_hitting_tm"]["queryResults"]["row"]
    
    # first ensure result is truthy
    if !!result

      # then handle for variations in the data formatting
      if result.class == Array
      
        # this is a sub-optimal solution that grabs stats only from a players stint on the team the ended the season with. We will refactor this down the road
        player[:avg] = result.last["avg"]
        player[:hr] = result.last["hr"]
        player[:h] = result.last["h"]
        player[:rbi] = result.last["rbi"]
        player[:ops] = result.last["ops"]
        # puts "#{counter}. From Array: #{player}"

      elsif result.class == Hash
        player[:avg] = result["avg"]
        player[:hr] = result["hr"]
        player[:h] = result["h"]
        player[:rbi] = result["rbi"]
        player[:ops] = result["ops"]
        # puts "#{counter}. From Hash: #{player}"
      else
        # puts "#{counter}. BLARG!"
      end
    end
  end
  # player_data_hashes
end

# uncomment the following line for testing this file alone
# teams = get_teams
# players = get_players(teams)
# add_stats_to_player_hashes(players)
