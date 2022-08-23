class Neighborhood < ApplicationRecord
  belongs_to :country, foreign_key: :country_id
  belongs_to :postal_code, class_name: 'PostalCode'
  belongs_to :city, class_name: 'City'
  belongs_to :state, class_name: 'State'
  belongs_to :municipality, class_name: 'Municipality'

  validates :name, presence: true, uniqueness: { case_sensitive: false, scope: [:country_id, :state_id, :city_id, :postal_code_id, :municipality_id] }

end
