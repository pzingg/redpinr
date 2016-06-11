class Fingerprint < ApplicationRecord

  belongs_to :measurement
  belongs_to :location

end
