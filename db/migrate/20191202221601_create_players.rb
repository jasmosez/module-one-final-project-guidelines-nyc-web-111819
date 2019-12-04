

class CreatePlayers < ActiveRecord::Migration[6.0]
  def change
    create_table :players do |t|
      t.string :mlb_player_id
      t.string :name
      t.string :position
      t.string :team 
      t.float  :avg
      t.integer :hr
      t.integer :rbi
      t.integer :h
      t.float   :ops
      
      t.timestamps
    end
  end
end
