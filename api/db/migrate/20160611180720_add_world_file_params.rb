class AddWorldFileParams < ActiveRecord::Migration[5.0]
  def change
    change_table :maps do |t|
      t.string :level
      t.string :crs
      t.string :zone
      t.float :scale_x
      t.float :skew_y
      t.float :skew_x
      t.float :scale_y
      t.decimal :top_left_x, precision: 64, scale: 12  
      t.decimal :top_left_y, precision: 64, scale: 12  
    end
  end
end
