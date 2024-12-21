class CreatePlayers < ActiveRecord::Migration[8.0]
  def change
    create_table :players do |t|
      t.string :name
      t.integer :chips, default: 1000
      t.string :cards, array: true, default: []
      t.references :room, null: true, foreign_key: true

      t.timestamps
    end
  end
end
