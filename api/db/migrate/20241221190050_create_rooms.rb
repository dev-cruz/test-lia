class CreateRooms < ActiveRecord::Migration[8.0]
  def change
    create_table :rooms do |t|
      t.string :name
      t.string :phase
      t.integer :max_players
      t.string :community_cards, array: true, default: []
      t.integer :pot, default: 0

      t.timestamps
    end
  end
end
