class FingerprintsController < ApplicationController
  before_action :set_fingerprint, only: [:show, :update, :destroy]

  # GET /fingerprints
  def index
    @fingerprints = Fingerprint.all

    render json: @fingerprints
  end

  # GET /fingerprints/1
  def show
    render json: @fingerprint
  end

  # POST /fingerprints
  def create
    @fingerprint = Fingerprint.new(fingerprint_params)

    if @fingerprint.save
      render json: @fingerprint, status: :created, location: @fingerprint, template: 'fingerprints/show'
    else
      render json: @fingerprint.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /fingerprints/1
  def update
    if @fingerprint.update(fingerprint_params)
      render json: @fingerprint, template: 'fingerprints/show'
    else
      render json: @fingerprint.errors, status: :unprocessable_entity
    end
  end

  # DELETE /fingerprints/1
  def destroy
    @fingerprint.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_fingerprint
      @fingerprint = Fingerprint.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def fingerprint_params
      params.require(:fingerprint).permit(:measurement_id, :location_id)
    end
end
