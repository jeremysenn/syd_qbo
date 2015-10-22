class TudDevicesController < ApplicationController
  before_filter :authenticate_user!, :except => [:show_scanned_jpeg_image, :send_scanned_jpeg_image]
#  load_and_authorize_resource

  # GET /tud_devices
  # GET /tud_devices.json
  def index
#    @tud_devices = TudDevice.all
    @tud_devices = current_user.tud_devices
  end

  # GET /tud_devices/1
  # GET /tud_devices/1.json
  def show
  end

  # GET /tud_devices/new
  def new
  end

  # GET /tud_devices/1/edit
  def edit
  end

  # POST /tud_devices
  # POST /tud_devices.json
  def create
    @tud_device = TudDevice.new(tud_device_params)

    respond_to do |format|
      if @tud_device.save
#        format.html { redirect_to images_path, notice: 'Tud device was successfully created.' }
        format.html { redirect_to @tud_device, notice: 'Tud device was successfully created.' }
        format.json { render :show, status: :created, location: @tud_device }
      else
        format.html { render :new }
        format.json { render json: @tud_device.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tud_devices/1
  # PATCH/PUT /tud_devices/1.json
  def update
    respond_to do |format|
      if @tud_device.update(tud_device_params)
        format.html { redirect_to @tud_device, notice: 'Tud device was successfully updated.' }
        format.json { render :show, status: :ok, location: @tud_device }
      else
        format.html { render :edit }
        format.json { render json: @tud_device.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tud_devices/1
  # DELETE /tud_devices/1.json
  def destroy
    @tud_device.destroy
    respond_to do |format|
      format.html { redirect_to tud_devices_url, notice: 'Tud device was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  def show_scanned_jpeg_image
    send_data TudDevice.drivers_license_scanned_image, :type => 'image/jpeg',:disposition => 'inline'
  end
  
  def send_scanned_jpeg_image
    send_data TudDevice.drivers_license_scanned_image, :type => 'image/jpeg',:disposition => 'attachment'
  end
  
  def drivers_license_scan
    scan_result_hash = TudDevice.drivers_license_scan
    respond_to do |format|
      format.html {}
#      format.json { render json: @item.unit_price }
#      format.json {render json: {"name" => @item.name, "description" => @item.description, "unit_price" => @item.unit_price} } 
      format.json {
        unless scan_result_hash.blank?
          render json: {
            "firstname" => scan_result_hash["FIRSTNAME"], "lastname" => scan_result_hash["LASTNAME"],
            "streetaddress" => scan_result_hash["ADDRESS1"], "city" => scan_result_hash["CITY"], "state" => scan_result_hash["STATE"], "zip" => scan_result_hash["ZIP"]
            } 
        else
          render json: {} 
        end
        } 
    end
  end
  
  def scale_read
    scale_read_result = TudDevice.scale_read
    respond_to do |format|
      format.html {}
      format.json {
        unless scale_read_result.blank?
          render json: { "weight" => scale_read_result } 
        else
          render json: {} 
        end
        } 
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tud_device
      @tud_device = TudDevice.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def tud_device_params
      params.require(:tud_device).permit(:show_thumbnails, :table_name)
    end
end
