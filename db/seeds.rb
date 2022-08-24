# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
country = Country.create(code: "MX")
  # state = State.create(code: 'DF', name: 'Mexico', country_id: country.id)
  # city = City.create(name: "Ciudad de Mexico", country_id: country.id, state_id: state.id)
  # municipality = Municipality.create(name: "Ciudad de Mexico", country_id: country.id, state_id: state.id, city_id: city.id)
  # postal_code = city.postal_codes.create(code: '11550', state_id: state.id, country_id: country.id, municipality_id: municipality.id)
  # neighborhood = Neighborhood.create(
  #   name: 'Polanco IV Seccion',
  #   country_id: country.id,
  #   state_id: state.id,
  #   city_id: city.id,
  #   postal_code_id: postal_code.id,
  #   municipality_id: municipality.id
  # )
