class Player < ActiveRecord::Base
  has_many :wishes
  has_many :wishlists, through: :wishes
end