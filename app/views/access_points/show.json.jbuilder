json.extract! @access_point, :id, :name, :bssid_base, :bssid_top, :building, :room, :created_at, :updated_at
json.href access_point_url(@access_point, format: :json)
json.map do
  json.extract! @access_point.location.map, :id, :name, :url
  json.href location_url(@access_point.location.map, format: :json)
end
json.location do
  json.extract! @access_point.location, :id, :name, :map_x, :map_y, :accuracy, :created_at, :updated_at
  json.href location_url(@access_point.location, format: :json)
end
