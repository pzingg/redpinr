class CreateAccessPoints < ActiveRecord::Migration
  def change
    create_table :access_points do |t|
      t.belongs_to :location
      t.string :name
      t.string :bssid_base
      t.string :bssid_top
      t.string :school
      t.string :room

      t.timestamps
    end
  end
end
