class AddIsActiveToPlayers < ActiveRecord::Migration[8.0]
  def change
    add_column :players, :is_active, :boolean, default: true
  end
end
