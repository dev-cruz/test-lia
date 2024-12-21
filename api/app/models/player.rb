class Player < ApplicationRecord
  belongs_to :rooms, optional: true
  validates :name, presence: true
end
