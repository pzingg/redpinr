json.extract! @map, :id, :name, :level, :url, :image_w, :image_h, :crs, :zone, :scale_x, :skew_y, :skew_x, :scale_y, :top_left_x, :top_left_y
json.href map_url(@map, format: :json)
