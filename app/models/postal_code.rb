class PostalCode < ApplicationRecord
  has_many :neighborhoods, dependent: :restrict_with_exception

  has_many :cities_postal_codes
  has_many :cities, through: :cities_postal_codes
  belongs_to :country, optional: false
  belongs_to :state
  belongs_to :municipality

  validates :code, uniqueness: { scope: [:country_id, :state_id, :municipality_id] }
end