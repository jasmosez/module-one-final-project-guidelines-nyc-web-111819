require_relative '../config/environment.rb'

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
  # Call team rosters. Return array of players

  url = "http://lookup-service-prod.mlb.com/json/named.roster_40.bam?team_id="
  players = []
  
  team_ids.each do |id| 
    response_string = RestClient.get(url + id)
    response_hash = JSON.parse(response_string)

    # iterate over team_ids. push to player_ids  
    response_hash["roster_40"]["queryResults"]["row"].each do |player|
      players << {
        mlb_player_id: player["player_id"],
        name: player["name_display_first_last"],
        position: player["position_txt"]
    }
    end
  end
  
  # be sure to return player_ids
  binding.pry  
  players
end

def get_player_stats(player_ids)
  # get season hitting stats data by player id. Return as a hash, ready to store in db
  
  # In this instance, we are hard coding 2019. Could parse for interporlation, in the future 
  url = "http://lookup-service-prod.mlb.com/json/named.sport_hitting_tm.bam?league_list_id='mlb'&game_type='R'&season='2019'&player_id="
  player_stats = {}

  player_ids.each do |id|
    response_string = RestClient.get(url + id)
    response_hash = JSON.parse(response_string)
  end


end


get_players(get_teams))
