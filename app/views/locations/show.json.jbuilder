json.extract! @location, :id, :name, :map_x, :map_y, :accuracy, :created_at, :updated_at
json.href location_url(@location, format: :json)
json.map do
  json.extract! @location.map, :id, :name, :url
  json.href map_url(@location.map, format: :json)
end
