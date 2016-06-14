json.array!(@locations) do |location|
  json.extract! location, :id
  json.href location_url(location, format: :json)
end
