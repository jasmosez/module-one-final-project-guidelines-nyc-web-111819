class Cli

  def self.run
    welcome     
    email = login_prompt #returns user inputted email
    user = login_validation(email) # returns user object once successful    
    login_success(user)
    while true 
      primary_menu(user) 
    end
  end
  
  def self.welcome           
    clear_screen
    ascii                                                                                                                                                                            
    puts "Hey, Slugger! Welcome to AllSTarzBaseball"
  end

  def self.login_prompt
    email = PROMPT.ask("Email:")
  end

  def self.login_validation(email)
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

  def self.register(email)
    
    # prompt for your name
    name = PROMPT.ask("Hey, slugger! What's your full name?")
    # create a new user
    user = User.create(name: name, email: email)
    # create a wishlist for the user
    # to make each wishlist unique and personable, we assign the user's email to the wishlist's name. This is because. in "MVP", we have only one wishlist per user
    wishlist = Wishlist.create(name: email, user_id: user.id)
    # MVP will have one and only one wishlist per user
  end

  def self.login_success(user)
    
     # returns current user instance 
    puts ""
    puts "Welcome, #{user.name}"
    status_message(wishlist_status(user))
  end 

  def self.wishlist_status(user)
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

  def self.complete?(wishlist)
    # returns true if there are at least three players in every position
    # NEED TO REMOVE OF
    POSITION_HASH.values.reduce do |bool, position|
      num_players = players_in_position(wishlist, position)
      bool = !!bool && num_players >= 3
    end
  end

  def self.status_message(status)
    case status
    
    when "empty"  
      puts "Your list is empty!".colorize(:red)
      puts "Time to scout and build your list!"
    
    when "incomplete"
      puts "Your list is still in progress!".colorize(:yellow)
      puts "Remember: you need AT LEAST 3 prospects per position."
    
    when "complete"
      puts "Your list is ready!".colorize(:green) 
      puts "But, you can keep adding players or rearranging as you like."

    end
    
  end

  def self.primary_menu(user)
    
    # Primary Navigation Prompt

    puts ""
    puts "MAIN MENU".colorize(:green)  
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

 

  def self.select_position_menu(user)
    clear_screen
    # Note that we are not offering the possibility to browse OF"

    options = POSITION_HASH

    options["All Players"] = "all"
    options["Back to Main Menu"] = "back"

    response = PROMPT.select("Which position(s) do you want to scout?", POSITION_HASH, per_page: 15)
    
    case response
    when "back"
      # no instructions will let the methods run their course and hit the end of the while loop in self.runand get us back to the main menu
    else
       # we're additing handling in self.player_view in order to test for "all" before calling the rest of the method as originally intended (just assuming it gets a position abbreviation string)
      player_view(user, response) 
    end
  end

  def self.player_view(user, position)
  # [see only one position-block at a time]
  # what is the default sorting? == Hits Descending
  # Are there additional sorting options == Not for MVP
  # QUESTION: how to include a "back" option
  
  
  # initialize new hash 
  clear_screen
  choices = {}

  if position == "all"
    # given status on wishlist
    wishlist_status(user)
    puts ""

    # generate list of all players
    items = Player.all.order(h: :desc)
  else
    # given status on wishlist / players needed in position
    players_needed = 3 - players_in_position(user.wishlists.first, position)
    if players_needed > 0
      puts "You need #{players_needed} more players at #{POSITION_HASH.key(position)}.".colorize(:yellow)
      puts ""
    else
      puts "You've got enough players at #{POSITION_HASH.key(position)}.".colorize(:red)
      puts ""
    end
    
    # generate the list of players playing position
    items = Player.where(position: position).order(h: :desc)
  end

  items.each do |z|
    #formatted string assign to key, player id assigned to value of choices hash    
   choices[format_player_data(z)] = z.id   
  end 
  
    selection = PROMPT.select(format_player_header, choices, per_page: 35, filter: true)
    
    # Assign selected player to wishlist
    assign_player_to_wishlist(user, selection)
  end 

  def self.players_in_position(wishlist, position)
    # returns number of players in a given position on a given wishlist
    players = wishlist.wishes.select do |wish| 
      wish.position == position 
    end
    players.length
  end

  def self.format_player_data(player)
    # returns a string of formatted player data
    z = player 
    choices = {}

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
    string_avg = z.avg.to_s
    # Check for an empty string to avoid getting "0000"
    if string_avg == ""
      formatted_avg = "    "
    else
      string_avg = z.avg.to_s.delete_prefix("0")
      multiplier = 4 - string_avg.length 
      formatted_avg = string_avg + '0' * multiplier
    end
    
    #format OPS for columns
    string_ops = z.ops.to_s
    # Check for an empty string to avoid getting "00000"
    if string_ops == ""
      formatted_ops = "     "
    else
      # case where OPS is less than 1.0
      if string_ops[0] == "0"
        string_ops = string_ops.delete_prefix("0")
        # add zeros for floats that extend less than three digits past the decimal
        multiplier = 4 - string_ops.length 
        formatted_ops = ' ' + string_ops + '0' * multiplier
      else
      # case where OPS is greater than 1.0
        # add zeros for floats that extend less than three digits past the decimal
        multiplier = 5 - string_ops.length 
        formatted_ops = string_ops + '0' * multiplier
      end
    end
    "#{formatted_name} | #{formatted_position} | #{formatted_h} | #{formatted_hr} | #{formatted_rbi} | #{formatted_avg} | #{formatted_ops} | #{z.team}"
  end

  def self.format_player_header
    "Select Your Player          | Pos |  H  | HR  | RBI | AVG  |  OPS  | Team".colorize(:green)
  end

  def self.assign_player_to_wishlist(user, player_id)
    existing_wish = user.wishlists.first.wishes.find do |wish|
      wish.player_id == player_id
    end
    
    if !existing_wish
      Wish.create(
        player_id: player_id, 
        wishlist_id: user.wishlists.first.id, 
        position: assign_position(player_id),
        rank: user.wishlists.first.wishes.length + 1
        )
    else
      puts ""
      puts "Woah. Slow down, Slugger! You've already got #{Player.find(player_id).name} on your list".colorize(:red)
    
      end

  end 

  def self.assign_position(selection)
    
    # binding.pry
    # give the option of appropriate field choices(an outfielder can only play outfield positions)
    mlb_position = Player.find(selection).position

    #get the options that this player can be assigned to on our wishlist
    position_group = POSITION_BLOCKS.values.find do |array|
      array.include?(mlb_position)
    end
    # add dh as an option for every circumstance 
    # binding.pry
    if !position_group.include?("DH")
      position_group.push("DH")
    end 

    # transforming abbreviations to full position name
    options = {}
    position_group.each do |position|
      options[POSITION_HASH.key(position)] = position 
      
    end

    # prompt user to assign position and return it
    # TO FIX. 
    
    PROMPT.select("Which position would you like to assign your player?", options)
    
  end 

  def self.wishlist_view(user)
    clear_screen
    # Render wishlist 
    render_wishlist(user)
    wishlist_menu(user)
  end

  def self.render_wishlist(user)
    
    wishes = user.wishlists.first.wishes
    wishes.to_a
    sorted_wishes = wishes.sort {|a, b| 
      # binding.pry
      a.rank <=> b.rank
    }
    
    # render standard header plus three extra spaces to allow for rank
    puts format_player_header.sub(/\s\s/, "     ")
    
      sorted_wishes.each do |wish|
        # ensure that wish position string segment takes up two chars
        if wish.position.length == 1 
          wish.position += " "
        end 
        
        #format rank numbering so that columns are clean up thru three digit ranks
        multiplier = 4 - wish.rank.to_s.length
        formatted_rank = wish.rank.to_s + '.' + ' ' * multiplier
        
        # Print each player with rank using helper format. 
        # Use Regex to swap in wish position for mlb player position
        puts formatted_rank + format_player_data(wish.player).sub(/\|\s../, "| " + wish.position)
      end
  end

  def self.wishlist_menu(user)  
    puts ""
    puts "WISHLIST MENU".colorize(:green)
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

  def self.drop_player(user)
    
    wishes = user.wishlists.first.wishes
    selection = PROMPT.ask("Choose a player to drop by their rank number (1 to #{wishes.length}):")  { |q| q.in("1-#{wishes.length}")}
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
    
    wishlist_view(user)
  end 


  def self.reassign_positions(user)
    
    wishes = user.wishlists.first.wishes
    selection = PROMPT.ask("Choose a player to re-assign their position by their rank number (1 to #{wishes.length}):")  { |q| q.in("1-#{wishes.length}")}
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
    wishlist_view(user)
  end 

  def self.rerank_players(user)
    
    wishes = user.wishlists.first.wishes
    selection = PROMPT.ask("Choose a player to re-rank by their rank number (1 to #{wishes.length}):") { |q| q.in("1-#{wishes.length}")}
    selection = selection.to_i
    # NEED TO force validation of selection (to be within the proper range)

    # find wish with rank of selection
    player_wish = wishes.find do 
      |wish| wish.rank == selection
    end

    new_rank = PROMPT.ask("What do you want to rank #{player_wish.player.name} (1 to #{wishes.length})") { |q| q.in("1-#{wishes.length}")}
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
      puts ""
      puts "C'mon, look alive! Thats already their rank!".colorize(:yellow)
      puts ""
    end
    
    # assign new rank to selected wish and save to db
    player_wish.rank = new_rank
    player_wish.save

   wishlist_view(user)
  end 

  def self.about_view(user)
    clear_screen
    # binding.pry

    puts "About AllSTarzBaseball...".colorize(:green)

    puts "* AllSTarz Baseball is a service that will set you up for success in your upcoming Fantasy Baseball draft." 
    puts "* Using the option to 'Browse and Select Players', simply create your 'Wishlist' of dream players." 
    puts "* You can add as many players to your wishlist as you would like."
    puts "* You need three players at each position for your list to be considered 'ready'." 
    puts "* Select 'View and Manage Wishlist' to view their stats and continuously add/drop/re-rank your players to your heart's content." 
    puts "* Ranking determines the order in wich you'll choose players (subject to availability, of course), so rank wisely!"
    puts "* The player database is orginating from the MLB API."
    puts "* Requires a terminal width of at least 130 chars"
    puts ""
    puts "* MLB API -> https://appac.github.io/mlb-data-api-docs/"
    puts "* Contributions: James Schaffer, Sean Tarzy, Tim Rines"
    puts ""
    about_menu(user)

  end

  def self.about_menu(user)
    puts ""
    puts "ABOUT MENU".colorize(:green)
    selection = PROMPT.select("Alright. Now, get back out there, Slugger!") do |menu|
    
      # Back to Main Menu
      menu.choice "Back to Main Menu"
    end

    case selection 
    when "Back to Main Menu"
    end
  end

  def self.clear_screen
    system 'clear'
  end

  def self.ascii
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
    puts ""
  end

  # STRETCH METHODS
  # def search_view
  # end
end
