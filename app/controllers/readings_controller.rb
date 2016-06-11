class ReadingsController < ApplicationController
  before_action :set_reading, only: [:show, :update, :destroy]

  # GET /readings
  def index
    @readings = Reading.all

    render json: @readings
  end

  # GET /readings/1
  def show
    render json: @reading
  end

  # POST /readings
  def create
    
    @reading = Reading.new(reading_params)

    if @reading.save
      render json: @reading, status: :created, location: @reading
    else
      render json: @reading.errors, status: :unprocessable_entity
    end
  end

  # POST /readings/apscan
  def apscan
    attrs = JSON.parse(apscan_params[:data])
    measurement = Measurement.find_or_create_by(tag: attrs.delete('mid'))
    attrs['measurement_id'] = measurement.id
    attrs['ht'] = 'Y'
    attrs['cc'] = 'US'
    sectype = attrs.delete('sectype')
    attrs['security'] = case sectype
      when 1
        'WEP'
      when 2
        'WPA'
      when 3
        'WPA2'
      when 0xFF
        'NOT_SET'
      else
        'NONE'
      end
    @reading = Reading.new(attrs)
    
    if @reading.save
      render json: @reading, status: :created, location: @reading, formats: [:json], template: 'readings/show'
    else
      render json: @reading.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /readings/1
  def update
    if @reading.update(reading_params)
      render json: @reading
    else
      render json: @reading.errors, status: :unprocessable_entity
    end
  end

  # DELETE /readings/1
  def destroy
    @reading.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_reading
      @reading = Reading.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def reading_params
      params.fetch(:reading, {})
    end
    
    def apscan_params
      # Particle webhook parameters figured out by use of requestb.in
      params.permit(:event, :data, :coreid, :published_at)
    end
end
