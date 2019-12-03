

def welcome
  puts "Hey, Slugger! Welcome to AllSTarzBaseball"
end

def login_prompt
  email = PROMPT.ask("Email:")
end

def login_validation(email)
  # returns current User instance or 'nil'
  User.find_by(email: email) 
end

def run
  welcome 
  email = login_prompt
  user = login_validation(email)
  if !!user
    login_success(user)
  else
    login_failure(email)
  end  
end

def login_failure(email)
  # we didn't find that email
  # do you want to register it or re-enter
end

def register(email)
  # prompt for your name
  # create a new user
  # create a wishlist for the user
  # MVP will have one and only one wishlist per user
end

def login_success(user)
  # returns current user instance 
  puts "Welcome, #{user.name}"
  status_message(wishlist_status(user))
  binding.pry
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
    binding.pry
    return "complete"
  else
    binding.pry
    return "incomplete"
  end
end 

def complete?(wishlist)
  positions = ["SS", "P", "1B", "3B", "C", "2B", "LF", "CF", "RF", "DH"]

  positions.reduce do |bool, position|
    players_in_position = wishlist.wishes.select do |wish| 
      wish.position == position 
    end
    binding.pry
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


def primary_menu
  # Browse and Select Players --> [Select position menu]
  # View Wishlist --> [Wishlist Menu]
  # Search by playername = STRETCH
  # About This App --> [About this App Interface]
  # Seac
end

def select_position_menu
  # --outfielders (according to MLB)
  # --infielders
  # --pitchers
  # --catchers
  # --DH-only
  # Back --> [Primary Nav]
end

def player_view
end

def wishlist_view
end


def about_view
end

def clear_screen
end

# STRETCH METHODS
# def search_view
# end
