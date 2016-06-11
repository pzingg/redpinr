json.array!(@maps) do |map|
  json.extract! map, :id
  json.href map_url(map, format: :json)
end
