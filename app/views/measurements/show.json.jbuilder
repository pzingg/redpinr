json.extract! @measurement, :id, :tag, :created_at
json.url measurement_url(@measurement, format: :json)
json.readings @measurement.readings do |reading|
  json.extract! reading, :id, :ssid, :bssid, :rssi, :channel
  json.href reading_url(reading, format: :json)
end
