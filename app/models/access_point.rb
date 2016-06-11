require 'csv'

class AccessPoint < ApplicationRecord

  belongs_to :location

  class << self

    # Aerohive models take 0x40 mac addresses
    def find_base_node(bssid)
      AccessPoint.where(['bssid_base<=? AND bssid_top>=?', bssid, bssid]).take
    end

    # Serial Number,Node ID,Host Name,Device Model,Device Function,Network Policy,
    # Location,Static IP Address,Netmask,Default Gateway,Topology Map,Country Code,
    # Wifi0 Radio Profile,Wifi0 Admin State,Wifi0 Operation Mode,Wifi0 Channel,
    # Wifi0 Power,Wifi1 Radio Profile,Wifi1 Admin State,
    # Wifi1 Operation Mode,Wifi1 Channel,Wifi1 Power,HiveOS,TAG1,TAG2,TAG3,VHM Name
    def import_from_aerohive(path)
      wild_card = 0x3F
      mask = (1 << 48) - 1 - wild_card
        
      CSV.foreach(path, row_sep: "\r\n", col_sep: ',', headers: true,
        header_converters: :symbol) do |row|
        bssid_base = row[:node_id].downcase  
        eui_top = (bssid_base.to_i(16) & mask) + wild_card
        bssid_top = sprintf("%012x", eui_top)
        
        # node_id for Kent-2 is '08EA447FCAC0'
        # ksd-student is '08:ea:44:7f:ca:d4'
        # ksd-guest is ' 08:ea:44:7f:ca:d5'
        school, room = row[:location].split(/[-_]+/, 2)
        room.gsub!(/[-_]+/, ' ')
        name = row[:host_name]
        location = Location.default
        location.access_points << AccessPoint.new(name: name, 
          bssid_base: bssid_base, bssid_top: bssid_top, school: school, room: room)
      end
    end

  end
end
