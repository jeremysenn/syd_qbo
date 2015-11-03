class DevicesController < ApplicationController
  before_filter :authenticate_user!, :except => [:show_scanned_jpeg_image]
#  load_and_authorize_resource

  before_action :set_device, only: [:show, :show_scanned_jpeg_image, :scale_read, :scale_camera_trigger, :drivers_license_scan]

  # GET /devices
  # GET /devices.json
  def index
#    @devices = Device.all
    @devices = current_user.devices
  end

  # GET /devices/1
  # GET /devices/1.json
  def show
  end

  # GET /devices/new
  def new
  end

  # GET /devices/1/edit
  def edit
  end

  # POST /devices
  # POST /devices.json
  def create
    @device = Device.new(device_params)

    respond_to do |format|
      if @device.save
#        format.html { redirect_to images_path, notice: 'Device was successfully created.' }
        format.html { redirect_to @device, notice: 'Device was successfully created.' }
        format.json { render :show, status: :created, location: @device }
      else
        format.html { render :new }
        format.json { render json: @device.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /devices/1
  # PATCH/PUT /devices/1.json
  def update
    respond_to do |format|
      if @device.update(device_params)
        format.html { redirect_to @device, notice: 'Device was successfully updated.' }
        format.json { render :show, status: :ok, location: @device }
      else
        format.html { render :edit }
        format.json { render json: @device.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /devices/1
  # DELETE /devices/1.json
  def destroy
    @device.destroy
    respond_to do |format|
      format.html { redirect_to devices_url, notice: 'Device was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  def show_scanned_jpeg_image
    send_data @device.drivers_license_scanned_image, :type => 'image/jpeg', :filename => 'drivers_license.jpg', :disposition => 'inline'
  end
  
  def drivers_license_scan
    scan_result_hash = @device.drivers_license_scan
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
    scale_read_result = @device.scale_read
    respond_to do |format|
      format.html {}
      format.json {
        unless scale_read_result.blank?
          render json: { "weight" => scale_read_result }, :status => :ok 
        else
          render :status => :unprocessable_entity
        end
        } 
    end
  end
  
  def scale_camera_trigger
    @device.scale_camera_trigger(params[:ticket_number], params[:event_code], params[:commodity_name], params[:location], params[:weight])
    respond_to do |format|
      format.html {}
      format.json { render json: {}, :status => :ok}
    end
  end
  
  def drivers_license_camera_trigger
    @device.drivers_license_camera_trigger
    respond_to do |format|
      format.html {}
      format.json { render json: {}, :status => :ok}
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_device
      @device = Device.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def device_params
      params.require(:device).permit(:show_thumbnails, :table_name)
    end
end
