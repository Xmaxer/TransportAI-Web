class Setting < ApplicationRecord
  belongs_to :user
  validates :price_per_km, presence: true
  validates :price_per_time, presence: true
  validates :user_id, presence: true
end
