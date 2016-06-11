json.array!(@readings) do |reading|
  json.extract! reading, :id
  json.url reading_url(reading, format: :json)
end
