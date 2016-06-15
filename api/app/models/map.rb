class Map < ApplicationRecord

  validates :name, presence: true, uniqueness: true
  validates :url, presence: true

  def initialize(params = {})
    handle_file_uploads(params)
    super
  end  

  def update(params = {})
    handle_file_uploads(params)
    super
  end
  
  def image_size
    @image_size ||= FastImage.size(self.url)
  end
  
  def image_w
    image_size ? image_size[0] : nil
  end

  def image_h
    image_size ? image_size[1] : nil
  end
  
  def valid_overlay?
    !self.url.nil? && self.url =~ /^http/ && self.zone && self.scale_x && 
      self.top_left_x && self.top_left_y
  end
        
  def overlay_string
    sprintf("\"%s\",\"%s\",%d,%d,%.2f,\"%s\",%.2f,%.2f", 
      self.url, self.level, self.image_w, self.image_h, self.scale_x, 
      self.zone, self.top_left_x, self.top_left_y)
  end
  
  # Extract uploaded temp files if they exist
  def handle_file_uploads(params) 

    # Parse uploaded ESRI world file
    world_file = params.delete(:world_file)
    if world_file
      values = world_file.read.strip.split(/\s+/).map { |v| v.to_f }
      if values.size == 6
        params[:scale_x] = values[0]
        params[:skew_y] = values[1]
        params[:skew_x] = values[2]
        params[:scale_y] = values[3]
        params[:top_left_x] = values[4]
        params[:top_left_y] = values[5]
      end
    elsif !params[:scale_x].nil?
      if params[:scale_y].nil?
        params[:scale_y] = -params[:scale_x].to_f
      end
      if params[:skew_y].nil?
        params[:skew_y] = 0.0
      end
      if params[:skew_x].nil?
        params[:skew_x] = 0.0
      end
    end

    # Save uploaded image file to overlays folder
    image_file = params.delete(:image_file)
    if image_file
      path = File.join('overlays', File.basename(image_file.original_filename))
      dest_path = File.join(Rails.root, 'public', path)
      FileUtils.cp image_file.path, dest_path
      params[:url] = 'http://localhost:3000/' + path
    end
    params
  end  

  def self.default
    unless @default
      @default = Map.where(name: 'DEFAULT').take
      unless @default
        @default = Map.create(name: 'DEFAULT', url: 'data:null')
      end
    end
    @default
  end
end
