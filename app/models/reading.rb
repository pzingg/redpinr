class Reading < ApplicationRecord

  belongs_to :measurement
  before_save :check_access_point

  def check_access_point
    self.wep_enabled = /WEP|WPA|EAP/.match(self.security || '')
    self.infrastructure_mode = true
    ap = AccessPoint.find_base_node(self.bssid)
  end
end
