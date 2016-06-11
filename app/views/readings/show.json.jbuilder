json.extract! @reading, :ssid, :bssid, :rssi, :channel
json.url reading_url(@reading, format: :json)
json.measurement do
  json.extract! @reading.measurement, :id, :tag, :created_at
  json.url measurement_url(@reading.measurement, format: :json)
end
