class Map < ApplicationRecord

  validates :name, presence: true, uniqueness: true
  validates :url, presence: true

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
