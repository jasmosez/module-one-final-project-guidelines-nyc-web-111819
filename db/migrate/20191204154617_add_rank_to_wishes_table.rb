class AddRankToWishesTable < ActiveRecord::Migration[6.0]
  def change
    add_column :wishes, :rank, :integer, after: :position
  end
end
