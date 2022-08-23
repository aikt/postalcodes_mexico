class CitiesPostalCode < ApplicationRecord
  belongs_to :postal_code
  belongs_to :city
end