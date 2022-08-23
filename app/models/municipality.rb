class Municipality < ApplicationRecord
  has_many :neighborhoods, dependent: :restrict_with_exception
  belongs_to :city, optional: false
  belongs_to :country, optional: false
  belongs_to :state
  validates :name,
            presence:true,
            uniqueness: {
              case_sensitive: false,
              scope: [:country_id, :city_id, :state_id]
            }
end