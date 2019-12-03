class Wish < ActiveRecord::Base
  belongs_to :wishlist 
  belongs_to :player 
end