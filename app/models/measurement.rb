class Measurement < ApplicationRecord

  ID_POS_CONTRIBUTION = 1.0
  ID_NEG_CONTRIBUTION = -0.4

  SIGNAL_CONTRIBUTION = 1.0
  SIGNAL_PENALTY_THRESHOLD = 10.0
  SIGNAL_GRAPH_LEVELING = 0.2

  # accuracy level
  LOCATION_KNOWN = 10.0
  LOCATION_UNKNOWN = 0.0
  LOCATION_THRESHOLD = 2.0
  
  has_one :fingerprint
  has_many :readings, -> { order(:rssi) }
  validates :tag, presence: true, uniqueness: true

  def access_points
    results = [ ]
    readings.each do |r|
      puts "checking #{r.rssi} #{r.ssid}"
      ap = AccessPoint.find_base_node(r.bssid)
      if ap
        results << [r, ap]
      end
    end
    results
  end
  
  def locate
    hits = SortedSet.new

    # check for similarity
    Fingerprint.find_each do |f|
      if similar?(f.measurement)
        hits.add(MeasurementComp.new(self, f.measurement, f.location))
      end
    end

    location = nil

    if !hits.empty?
      best_match = hits.first
      location = best_match.location
      accuracy = similarity_level(best_match.measurement)
      location.update(accuracy: accuracy)
    end

    location
  end
  
  def predict   
    predictor = SvmPredictor.new('svm_model.txt', 'categories.yml')
    model = predictor.train(Fingerprint.recent.all)
    if model
      location, probabilities = predictor.predict(self, model)
      location
    else
      nil
    end
  end
  
  def similar?(m1)
    similarity_level(m1) > LOCATION_THRESHOLD
  end
  
  def similarity_level(m1)
    Measurement.similarity_level(m1, self)
  end

  class << self
  
    def scan_and_fingerprint(loc_name, map_name=nil, map_x=0, map_y=0)
      measurement = scan
      map = map_name ? Map.where(name: map_name).take : nil    
      location = Location.create(map: map, name: loc_name, x: map_x, y: map_y)
      Fingerprint.create(location: location, measurement: measurement)
    end

    def scan_and_locate
      measurement = scan
      measurement.locate
    end
  
    def scan_and_predict
      measurement = scan
      measurement.predict
    end
    
    # computes the credit contributed by the received signal strength of any
    # wireless scan
    def signal_contribution(rssi1, rssi2)
      contribution = SIGNAL_CONTRIBUTION

      # we take the reference value of the rssi as base for further computations
      base = rssi1.abs.to_f

      # in order that +20 and -20 dB are treated the same, the penalty
      # function uses the difference of the rssi's
      diff = (rssi1 - rssi2).abs.to_f

      # prevent division by zero
      if diff != 0 && base != 0
        # get percentage of error
        x = diff / base
  
        # small error should result in a high contribution, big error in a
        # small -> reciprocate (1/x) MIN = 1, MAX = infinity
        y = 1.0 / x

        # compute percentage of treshold regarding the current base
        t = SIGNAL_PENALTY_THRESHOLD / base

        # shift down the resulting graph. the root (zero) will then be
        # exactly at x = treshold for every base, e.g. measurement, and
        # signal differences above the treshold will result in a negative
        # contribution
        y -= 1.0 / t

        # graph increases fast, so that a difference of 15 still results in
        # a maximal contribution. With this adjustment, the graph gets flat
        # and this has also an impact on the penalty (difference too big)
        y *= SIGNAL_GRAPH_LEVELING

        if (-SIGNAL_CONTRIBUTION <= y) && (y <= SIGNAL_CONTRIBUTION)
          contribution = y
        end
      end
  
      contribution
    end

    def similiarity_level(m1, m2)
      matches = 0    
      account = 0.0
      m1_readings = m1.readings
      m2_readings = m2.readings
      m1_readings.each do |m1_reading|
        m2_readings.each do |m2_reading|
    
          # bssid match: add ID contribution and signal strength contribution
          if m1_reading.bassid && m1_reading.bssid == m2_reading.bssid
            matches += 1
            account += ID_POS_CONTRIBUTION
            account += signal_contribution(m1_reading.rssi, m2_reading.rssi)
          end
        end
      end

      # penalty for each net that did not match
      readings = max(m1_readings.count, m2_readings.count)
      account += (readings - matches) * ID_NEG_CONTRIBUTION
      
      # a negative account results immediately in accuracy equals zero
      accuracy = 0
      if account > 0
  
        # get the total credit for this measurement.
        total_credit = 0.0
        total_credit += m1_readings.count * ID_POS_CONTRIBUTION
        total_credit += m1_readings.count * SIGNAL_CONTRIBUTION

        # get accuracy level defined by bounds
        factor = LOCATION_KNOWN - LOCATION_UNKNOWN;
  
        # compute percentage of account from totalCredit -> [0,1]; stretch
        # by accuracy span -> [0,MAX]; and in case min accuracy would not
        # be zero, add this offset
        a = (account / total_credit) * factor + LOCATION_UNKNOWN

        accuracy = a.round
      end
  
      accuracy
    end
  
  end
end
