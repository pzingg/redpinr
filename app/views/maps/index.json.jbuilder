json.array!(@maps) do |map|
  json.extract! map, :id, :name, :level, :url
  json.href map_url(map, format: :json)
end
