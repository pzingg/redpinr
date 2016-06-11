class CreateMeasurements < ActiveRecord::Migration[5.0]
  def change
    create_table :measurements do |t|
      t.string :tag
      
      t.datetime :created_at, null: false
    end
  end
end
