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
  "Designated Hitter" => "DH"
}

POSITION_BLOCKS = {
  :outfielders => ["LF", "CF", "RF"],
  :infielders => ["1B", "2B", "3B", "SS"],
  :pitchers => ["P"],
  :catchers => ["C"],
  :designated_hitters => ["DH"]
}

def welcome
  puts "Hey, Slugger! Welcome to AllSTarzBaseball"
end

def login_prompt
  email = PROMPT.ask("Email:")
end

def login_validation(email)
  # returns current User instance or 'nil'
  
  until !!User.find_by(email: email) 
  
    #prompt user response to missing email
    choice = PROMPT.select("Swing and a miss! We didn't find any sluggers by that email") do |menu|
        menu.choice "Register New Slugger Account"
        menu.choice "Re-Enter Email"
        menu.choice "Exit"
    end  

    # case for user choice
    case choice
    when "Register New Slugger Account"
      register(email)
    when "Re-Enter Email"
      # Re-Prompt email method
      email = login_prompt 
    when "Exit"
      exit
    end
    
  end
  User.find_by(email: email)
end

def register(email)
  # prompt for your name
  name = PROMPT.ask("Hey, slugger! What's your full name?")
  # create a new user
  user = User.create(name: name, email: email)
  # create a wishlist for the user
  # to make each wishlist unique and personable, we assign the user's email to the wishlist's name. This is because. in "MVP", we have only one wishlist per user
  wishlist = Wishlist.create(name: email, user_id: user.id)
  # MVP will have one and only one wishlist per user
end

def login_success(user)
  # returns current user instance 
  puts "Welcome, #{user.name}"
  status_message(wishlist_status(user))
end 

def wishlist_status(user)
  # if the users wishlist is empty, then the status will be "empty"
  # if the users wishlist has 3 players per position filled, the status will be "complete"
  # otherwise, "incomplete"
  
  # MVP forces one and only one wishlist per user
  list = user.wishlists.first
  
  if list.wishes.count == 0
    return "empty"
  elsif complete?(list)
    return "complete"
  else
    return "incomplete"
  end
end 

def complete?(wishlist)
  # positions = ["SS", "P", "1B", "3B", "C", "2B", "LF", "CF", "RF", "DH"]
  
  POSITION_HASH.values.reduce do |bool, position|
    players_in_position = wishlist.wishes.select do |wish| 
      wish.position == position 
    end
    bool = !!bool && players_in_position.count >= 3
  end
end

def status_message(status)
  case status
  when "empty"
    puts "Your list is empty! Time to scout and build your list!"
  when "incomplete"
    puts "Your list is still in progress. Remember: you need AT LEAST 3 prospects per position."
  when "complete"
    puts "Your list is ready! But, you can keep adding players or rearranging as you like."
  end
end

def primary_menu(user)
  # Primary Navigation Prompt
  
    response = PROMPT.select("Where do you want to go?") do |menu|
        menu.choice "Browse and Select Players"
        menu.choice "View and Manage My List"
        menu.choice "Learn More About This App"
        menu.choice "Exit"
    end  

    # case for user choice
    case response
    when "Browse and Select Players"
      select_position_menu(user) #this in turn calls player_view
    when "View and Manage My List"
      wishlist_view(user)
    when "Learn More About This App"
      about_view(user)
    when "Exit"
      exit
    end
end

def run
  welcome 
  email = login_prompt #returns user inputted email
  user = login_validation(email) # returns user object once successful
  login_success(user)
  while true 
    # binding.pry
    primary_menu(user) 
  end
end

def select_position_menu(user)
  # Note that we are not offering the possibility to browse OF"
  response = PROMPT.select("Which position(s) do you want to scout?", POSITION_HASH)
  player_view(user, response) 
end

def player_view(user, position)
  # [see only one position-block at a time]
  # what is the default sorting? == Hits Descending
  # Are there additional sorting options == Not for MVP
  # QUESTION: how to include a "back" option
  
  
  # initialize new hash 
  choices = {}
  items = Player.where(position: position).order(h: :desc)

  items.each do |z|
    #formatted string assign to key, player id assigned to value of choices hash
    
    #format NAME for columns
    multiplier = 25 - z.name.length 
    formatted_name = z.name + ' ' * multiplier

    #format POSITION for columns
    multiplier = 3 - z.position.length 
    formatted_position = z.position + ' ' * multiplier

    #format HITS for columns
    multiplier = 3 - z.h.to_s.length 
    formatted_h = z.h.to_s + ' ' * multiplier

    #format HOMERUNS for columns
    multiplier = 3 - z.hr.to_s.length 
    formatted_hr = z.hr.to_s + ' ' * multiplier

    #format RBIs for columns
    multiplier = 3 - z.rbi.to_s.length 
    formatted_rbi = z.rbi.to_s + ' ' * multiplier

    #format AVG for columns
    string_avg = z.avg.to_s.delete_prefix("0")
    multiplier = 4 - string_avg.length 
    formatted_avg = string_avg + '0' * multiplier
    
    #format OPS for columns
    string_ops = z.ops.to_s
    if string_ops[0] == "0"
      string_ops = string_ops.delete_prefix("0")
      multiplier = 4 - string_ops.length 
      formatted_ops = ' ' + string_ops + '0' * multiplier
    else
      multiplier = 5 - string_ops.length 
      formatted_ops = string_ops + '0' * multiplier
    end

    choices["#{formatted_name} | #{formatted_position} | #{formatted_h} | #{formatted_hr} | #{formatted_rbi} | #{formatted_avg} | #{formatted_ops} | #{z.team}"] = z.id   
  end

  # Prompt user to select a player
  # Do we want this to be a multi-select
  selection = PROMPT.select("Select Your Player          | Pos |  H  | HR  | RBI |  AVG |   OPS | Team", choices)
  
  # Insert validation to ensure we haven't already selected this player

  # Assign selected player to wishlist
  assign_player_to_wishlist(user, selection)
  
  # Prompt user to decide what to do next
  # intermediate menu? or back to main menu

end 

def assign_player_to_wishlist(user, selection)
  Wish.create(
    player_id: selection, 
    wishlist_id: user.wishlists.first.id, 
    position: assign_position(selection),
    rank: user.wishlists.first.wishes.length + 1
    )
end 

def assign_position(selection)
  # give the option of appropriate field choices(an outfielder can only play outfield positions)
  mlb_position = Player.find(selection).position

  #get the options that this player can be assigned to on our wishlist
  position_group = POSITION_BLOCKS.values.find do |array|
    array.include?(mlb_position)
  end

  options = position_group.map { |item|
    POSITION_HASH.key(item)
  }

  # prompt user to assign position and return it
  # TO FIX. 
  # 1. Have menu options be full position name (not just shorthand string)
  # 2. Not accounting for OF
  position_selection = PROMPT.select("Which position would you like to assign your player?", position_group) 
end 

def wishlist_view(user)
  # Render wishlist 
  render_wishlist(user)
  wishlist_menu(user)
end

def render_wishlist(user)
  wishes = user.wishlists.first.wishes
  wishes.to_a
  sorted_wishes = wishes.sort {|a, b| 
    # binding.pry
    a.rank <=> b.rank
  }
  
  puts "Player | Position | Hits | Homeruns | RBI | AVG | OPS"
  
    sorted_wishes.each do |wish|
      z = wish.player
      puts "#{wish.rank}. #{z.name} | #{wish.position} | #{z.h} | #{z.hr} | #{z.rbi} | #{z.avg} | #{z.ops} | #{z.team}"
    end
end

def wishlist_menu(user)  
  puts "WISHLIST MENU"
  sleep(0.5)
  selection = PROMPT.select("What do you want to do with your list?") do |menu|
    # Re-order (change rank)
    menu.choice "Re-rank Player(s)"
    # Re-assign position
    menu.choice "Re-assign Position(s)"
    # Remove a player from wishlist --> are you sure?
    menu.choice "Drop Player(s)"
    # STRETCH: Ability to search and add a player
    # STRETCH: Wipe entire wishlist --> are you sure? --> for real?
    # Back to Main Menu
    menu.choice "Back to Main Menu"
  end

  case selection 
  when "Re-rank Player(s)"
    rerank_players(user)
  when "Re-assign Position(s)"
    reassign_positions(user)
  when "Drop Player(s)"
    drop_player(user)
    #DESTROY wish 
  when "Back to Main Menu"
  end
end

def drop_player(user)
  wishes = user.wishlists.first.wishes
  selection = PROMPT.ask("Choose a player to drop by their rank number (1 to #{wishes.length}):") 
  selection = selection.to_i
  # find wish with rank of selection
  player_wish = wishes.find do 
    |wish| wish.rank == selection
  end
  player_wish.destroy 
  deleted_rank = player_wish.rank
  wishes.each do |wish|
    if wish.rank > deleted_rank
      wish.rank -= 1
      wish.save
    end
  end 
  binding.pry 
end 
def reassign_positions(user)
  wishes = user.wishlists.first.wishes
  selection = PROMPT.ask("Choose a player to re-assign their position by their rank number (1 to #{wishes.length}):")
  selection = selection.to_i
  # find wish with rank of selection
  player_wish = wishes.find do 
    |wish| wish.rank == selection
  end
  player_id = player_wish.player_id 
  new_position = assign_position(player_id)
  player_wish.position = new_position
  player_wish.save  
  #takes in a player_id and returns the position you will assign it to  
   # re-render wishlist with changes
  render_wishlist(user)
  #re-call wishlist nav
  wishlist_menu(user)
  binding.pry 
end 

def rerank_players(user)
  wishes = user.wishlists.first.wishes

  selection = PROMPT.ask("Choose a player to re-rank by their rank number (1 to #{wishes.length}):")
  selection = selection.to_i
  # NEED TO force validation of selection (to be within the proper range)

  # find wish with rank of selection
  player_wish = wishes.find do 
    |wish| wish.rank == selection
  end

  new_rank = PROMPT.ask("What do you want to rank #{player_wish.player.name} (1 to #{wishes.length})")
  new_rank = new_rank.to_i
  # NEED TO force validation of new rank
  
  # Depending on up-ranking or down-ranking, adjust all the other wishes that need adjusting (and save to db)
  if new_rank < selection 
    # selection is assigned to new_rank, and everything is shifted towards the back of array
    wishes.each do |wish| 
      if wish.rank < selection && wish.rank >= new_rank 
        wish.rank += 1
        wish.save
      end
    end
  elsif new_rank > selection
    wishes.each do |wish|
      if wish.rank > selection && wish.rank <= new_rank
        wish.rank -= 1
        wish.save
      end
    end
    
  else 
    puts "C'mon, look alive! Thats already their rank!"
  end
  
  # assign new rank to selected wish and save to db
  player_wish.rank = new_rank
  player_wish.save

  # re-render wishlist with changes
  render_wishlist(user)
  #re-call wishlist nav
  wishlist_menu(user)
end 

def about_view(user)
  binding.pry
  # COMPLETE means at least three per position
  # Credits
  # For more advanced stats, check out these sites...

end

def clear_screen
end

# STRETCH METHODS
# def search_view
# end
