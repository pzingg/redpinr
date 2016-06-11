json.extract! @map, :id, :name, :url
json.href map_url(@map, format: :json)
