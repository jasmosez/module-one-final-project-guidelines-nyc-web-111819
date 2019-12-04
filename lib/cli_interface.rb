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
    primary_menu(user) 
    binding.pry
  end
end

def select_position_menu(user)
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
    choices["#{z.name} | #{z.position} | #{z.h} | #{z.hr} | #{z.rbi} | #{z.avg} | #{z.ops} | #{z.team}"] = z.id   
  end

  # Prompt user to select a player
  selection = PROMPT.select("Select your player | position | hits | homers | RBI's | AVG | OPS", choices)
  
  # Assign selected player to wishlist
  assign_player_to_wishlist(user, selection)
  
  # Prompt user to decide what to do next
  # intermediate menu

end 

def assign_player_to_wishlist(user, selection)
  Wish.create(
    player_id: selection, 
    wishlist_id: user.wishlists.first.id, 
    position: assign_position(selection)
    )
end 

def assign_position(selection)
  # give the option of appropriate field choices(an outfielder can only play outfield positions)
  mlb_position = Player.find(selection).position

  #get the options that this player can be assigned to on our wishlist
  position_group = POSITION_BLOCKS.values.find do |array|
    array.include?(mlb_position)
  end

  # prompt user to assign position and return it
  # TO FIX. Have menu options be full position name (not just shorthand string)
  position_selection = PROMPT.select("Which position would you like to assign your player?", position_group) 
end 

def wishlist_view(user)
end


def about_view(user)
end

def clear_screen
end

# STRETCH METHODS
# def search_view
# end
