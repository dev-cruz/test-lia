class Room < ApplicationRecord
  has_many :players
  validates :name, presence: true
  validates :max_players, presence: true

  def current_players
    players.ids
  end
end
