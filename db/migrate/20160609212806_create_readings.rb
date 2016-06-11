class CreateReadings < ActiveRecord::Migration
  def change
    create_table :readings do |t|
      t.belongs_to :measurement
      t.string :ssid
      t.string :bssid
      t.integer :rssi
      t.integer :channel
      t.string :ht
      t.string :cc
      t.string :security
      t.boolean :wep_enabled
      t.boolean :infrastructure_mode
    end
  end
end
