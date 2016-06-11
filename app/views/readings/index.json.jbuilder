json.array!(@readings) do |reading|
  json.extract! reading, :id
  json.href reading_url(reading, format: :json)
end
