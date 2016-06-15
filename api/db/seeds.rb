# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# Import access point locations if aerohive.csv file exists
aerohive_data_file = Rails.root.join('db', 'aerohive.csv')
if File.exist? aerohive_data_file
  AccessPoint.import_from_aerohive aerohive_data_file
end

# Create default map and location
location = Location.default

# Import some maps
map_data_file = Rails.root.join('db', 'maps.yml')
if File.exist? map_data_file
  maps = YAML::load_file map_data_file
  
  # Put files into public/overlays
  map_files = maps.map { |m| Rails.root.join('db', m['url'].gsub(/^.+\//, '')) }
  FileUtils.cp map_files, Rails.root.join('public', 'overlays')
  
  # Create db records
  Map.create! maps
end
