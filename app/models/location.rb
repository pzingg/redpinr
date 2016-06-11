class Location < ApplicationRecord

  has_many :access_points
  validates :name, presence: true, uniqueness: true
  
  def self.default
    unless @default
      @default = Location.where(name: 'DEFAULT').take
      unless @default
        @default = Location.create(name: 'DEFAULT')
      end
    end
    @default
  end
end
