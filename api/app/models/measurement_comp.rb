class MeasurementComp
  include Comparable
  
  attr_reader :measurement, :location
  
  def initialize(basis, m, loc)
    @basis = basis
    @measurement = m
    @location = loc
  end
  
  def <=>(other)
    a1 = @basis.similarity_level(self.measurement)
    a2 = @basis.similarity_level(other.measurement)
    a1 == a2 ? self.created_at <=> other.created_at : a1 <=> a2
  end
end
