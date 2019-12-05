class Cli

  def self.run
    
    welcome     
    email = login_prompt #returns user inputted email
    user = login_validation(email) # returns user object once successful
    # binding.pry
    
    login_success(user)
    
    while true 
      # binding.pry
      primary_menu(user) 
    end
  end
  
  def self.welcome           
                                                                                                                                                                                                              
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
    

    
    POSITION_HASH.values.reduce do |bool, position|
      players_in_position = wishlist.wishes.select do |wish| 
        wish.position == position 
      end
      bool = !!bool && players_in_position.count >= 3
    end
  end

  def self.status_message(status)
    clear_screen
    case status
    when "empty"
      
      puts ""
      puts ""
      puts "Your list is empty!".colorize(:red)
      puts "Time to scout and build your list!"
      puts ""
      puts ""
    when "incomplete"
      
      puts ""
      puts ""
      puts "Your list is still in progress!".colorize(:yellow)
      puts "Remember: you need AT LEAST 3 prospects per position."
      puts ""
      puts ""
    when "complete"
      
      puts ""
      puts ""
      puts "Your list is ready!".colorize(:green) 
      puts "But, you can keep adding players or rearranging as you like."
      puts ""
      puts ""
    end
    
  end

  def self.primary_menu(user)
    
    # Primary Navigation Prompt

    puts ""
    puts "MAIN MENU".colorize(:pink)  
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
    response = PROMPT.select("Which position(s) do you want to scout?", POSITION_HASH, per_page: 11)
    player_view(user, response) 
  end

  def self.player_view(user, position)
    
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
    # Do we want this to be a multi-select
    clear_screen
    selection = PROMPT.select("Select Your Player | Position | Hits | Homeruns | RBI | AVG | OPS", choices, per_page: 35)
    
    # Insert validation to ensure we haven't already selected this player

    # Assign selected player to wishlist
    assign_player_to_wishlist(user, selection)
    
    # Prompt user to decide what to do next
    # intermediate menu? or back to main menu

  end 

  def self.assign_player_to_wishlist(user, selection)
    
    Wish.create(
      player_id: selection, 
      wishlist_id: user.wishlists.first.id, 
      position: assign_position(selection),
      rank: user.wishlists.first.wishes.length + 1
      )
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
    options = position_group.map do |position|
      POSITION_HASH.key(position)
    end

    # prompt user to assign position and return it
    # TO FIX. 
    
    PROMPT.select("Which position would you like to assign your player?", options)
    
  end 

  def self.wishlist_view(user)
    
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
    
    puts "Player | Position | Hits | Homeruns | RBI | AVG | OPS"
    
      sorted_wishes.each do |wish|
        z = wish.player
        puts "#{wish.rank}. #{z.name} | #{wish.position} | #{z.h} | #{z.hr} | #{z.rbi} | #{z.avg} | #{z.ops} | #{z.team}"
      end
  end

  def self.wishlist_menu(user)  
    puts ""
    puts "WISHLIST MENU".colorize(:pink)
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
    # binding.pry 
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
    render_wishlist(user)
    #re-call wishlist nav
    wishlist_menu(user)
    # binding.pry 
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

    # re-render wishlist with changes
    render_wishlist(user)
    #re-call wishlist nav
    wishlist_menu(user)
  end 

  def self.about_view(user)
    
    # binding.pry

    # COMPLETE means at least three per position
    # Credits
    # For more advanced stats, check out these sites...

  end

  def self.clear_screen
    system 'clear'
  end

  # STRETCH METHODS
  # def search_view
  # end
end
