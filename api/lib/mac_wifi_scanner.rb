require 'open3'

class MacWifiScanner

  AIRPORT_CMD_PATH = '/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport'

  def self.scan(ssid_match)
    measurement = nil
    stdout, stdeerr, status = Open3.capture3(AIRPORT_CMD_PATH + ' -s')
    lines = stdout.split("\n")
    lines.shift
    lines.each_with_index do |line, i|
      if measurement.nil?
        measurement = Measurement.create
      end
      ssid, bssid, rssi, channel, ht, cc, security = line.strip.split(/\s+/, 7)
      if ssid =~ ssid_match
        measurement.readings << Reading.new(ssid: ssid, bssid: bssid, 
          rssi: rssi.to_i, channel: channel.to_i, ht: ht, cc: cc, security: security)
      end
    end
  end
end
