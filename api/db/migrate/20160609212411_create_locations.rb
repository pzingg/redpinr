class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.belongs_to :map
      t.string :name
      t.float :map_x
      t.float :map_y
      t.float :accuracy

      t.timestamps
    end
  end
end
