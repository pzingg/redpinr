json.extract! @measurement, :id, :tag, :created_at
json.url measurement_url(@measurement, format: :json)
json.readings @measurement.readings do |reading|
  json.extract! reading, :ssid, :bssid, :rssi, :channel
  json.url reading_url(reading, format: :json)
end
