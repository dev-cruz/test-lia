class AddTurnAndBetToRooms < ActiveRecord::Migration[8.0]
  def change
    add_column :rooms, :current_turn, :integer, default: 1
    add_column :rooms, :current_bet, :integer, default: 0
  end
end
