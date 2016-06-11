class CreateFingerprints < ActiveRecord::Migration[5.0]
  def change
    create_table :fingerprints do |t|
      t.belongs_to :measurement
      t.belongs_to :location
      
      t.datetime :created_at, null: false
    end
  end
end
