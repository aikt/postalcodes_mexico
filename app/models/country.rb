class Country < ApplicationRecord
  has_many :neighborhoods, dependent: :restrict_with_exception
  has_many :cities, dependent: :restrict_with_exception
  has_many :states, dependent: :restrict_with_exception
  has_many :postal_codes, dependent: :restrict_with_exception
  has_many :municipalities, dependent: :restrict_with_exception

  validates :code, presence: true, uniqueness: { case_sensitive: false }
end
