class City < ApplicationRecord
  belongs_to :country, optional: false
  belongs_to :state
  has_many :neighborhoods, dependent: :restrict_with_exception
  has_many :cities_postal_codes
  has_many :municipalities
  has_many :postal_codes, through: :cities_postal_codes

  validates :name, presence: true, uniqueness: { case_sensitive: false, scope: [:country_id, :state_id] }
end