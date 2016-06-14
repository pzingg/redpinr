class SvmLocator

  def intialize(fname_model, fname_labels)
    @fname_model = fname_model
    @fname_labels = fname_labels
    build_categories
  end

  def build_categories
    locations = SortedSet.new
    bssids = SortedSet.new
  
    Fingerprint.find_each do |f|
      location_tag = f.location_id
      locations.add(location_tag)
      m = f.measurement.readings.each do |r|
        bssids.add(r.bssid)
      end
    end
    
    @locations = locations.to_a
    @bssids = bssids.to_a
  end
  
  def save_categories
    File.open(@fname_labels, 'w') do |f|
      data = { 'locations' => @locations, 'bssids' => @bssids }
      YAML.dump(data, f)
    end
  end
  
  def load_categories
    @locations.clear
    File.open(@fname_labels, 'r') do |f|
      cats = YAML.load(f)
      @locations = cats['locations']
      @bssids = cats['bssids']
    end
  end

  def to_example(m)
    values = { }
    m.readings.each do |r|
      bssid_i = @bssids.find_index(r.bssid)
      if !bssid_i.nil?
        values[bssid_i] = r.rssi.to_f
      end
    end
    values.empty? ? nil : Libsvm::Node.features(values)
  end
  
  def build_examples(fingerprints)
    # svm file format. each line is location with bssids, sorted by bssid_index
    # <location_index> <bssid_index>:<rssid> <bssid_index>:<rssid> ...
    # <location_index> is the label
    # <bssid_index>:<rssid> are the features as a hash <int>:<float>

    labels = [ ]
    examples = [ ]
    vector_size = bssids.size
    
    fingerprints.each do |f|
      loc_i = @locations.find_index(f.location_id)
      if !loc_i.nil?
        example = to_example(f.measurement)
        if !example.nil?
          labels << loc_i
          examples << example
        end
      end
    end
    
    [labels, examples]
  end

  def train(fingerprints)
    labels, examples = build_examples(fingerprints)
    if labels.empty?
      return nil
    end
    
    sp = Libsvm::Problem.new
    sp.set_examples(labels, examples)

    # define kernel parameters
    pa = Libsvm::Parameter.new
    pa.cache_size = 1 # in megabytes
    pa.eps= 0.001
    pa.c = 10
    pa.kernel_type = 'Linear'

    model = Libsvm::Model.train(sp, pa)

    save_categories
    model.save(@fname_model)

    model
  end

  def predict(m, model)
    if model.nil?
      model = Libsvm::Model.load(@fname_model)
      load_categories
    end
    
    label, pvalues = model.predict_probability(example)
    location = Location.find(@locations[label.to_i])
    
    probabilities = [ ]
    pvalues.each_with_index do |v, i|
      probabilities << [ @locations[i], v ]
    end
    
    location, probabilities
  end
end
