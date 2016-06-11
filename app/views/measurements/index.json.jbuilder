json.array!(@measurements) do |measurement|
  json.extract! measurement, :id
  json.href measurement_url(measurement, format: :json)
end
