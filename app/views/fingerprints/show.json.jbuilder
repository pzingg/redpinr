json.extract! @fingerprint, :id, :created_at
json.href fingerprint_url(@fingerprint, format: :json)
json.map do
  json.extract! @fingerprint.location.map, :id, :name, :url
  json.href map_url(@fingerprint.location.map, format: :json)
end
json.location do
  json.extract! @fingerprint.location, :id, :name, :map_x, :map_y, :accuracy, :created_at, :updated_at
  json.href location_url(@fingerprint.location, format: :json)
end
json.measurement do
  json.extract! @fingerprint.measurement, :id, :tag, :created_at
  json.url measurement_url(@fingerprint.measurement, format: :json)
  json.readings @fingerprint.measurement.readings do |reading|
    json.extract! reading, :ssid, :bssid, :rssi, :channel
    json.href reading_url(reading, format: :json)
  end
end
