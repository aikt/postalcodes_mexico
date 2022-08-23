class State < ApplicationRecord
  belongs_to :country, optional: false
  has_many :neighborhoods, dependent: :restrict_with_exception
  has_many :cities

  validates :name, presence: true, uniqueness: { case_sensitive: false, scope: [:country_id] }
end