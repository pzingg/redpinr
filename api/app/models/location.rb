class Location < ApplicationRecord

  belongs_to :map
  has_many :access_points
  validates :name, presence: true, uniqueness: true
  
  def self.default
    unless @default
      @default = Location.where(name: 'DEFAULT').take
      unless @default
        @default = Location.create(name: 'DEFAULT', map: Map.default)
      end
    end
    @default
  end
end
