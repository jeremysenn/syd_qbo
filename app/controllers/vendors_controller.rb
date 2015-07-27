class VendorsController < ApplicationController
  before_filter :authenticate_user!
#  load_and_authorize_resource

  before_action :set_vendor_service, only: [:index, :show, :create, :edit, :update, :update_qb, :destroy]
  before_action :set_vendor, only: [:show, :edit, :update, :update_qb, :destroy]

  # GET /vendors
  # GET /vendors.json
  def index
#    @vendors = Vendor.all
#    @vendors = current_user.vendors
    @vendors = @vendor_service.query(nil, :per_page => 1000)
  end

  # GET /vendors/1
  # GET /vendors/1.json
  def show
    
  end

  # GET /vendors/new
  def new
  end

  # GET /vendors/1/edit
  def edit
  end
  
  # POST /vendors
  # POST /vendors.json
  def create
    @qb_vendor = Quickbooks::Model::Vendor.new
    @qb_vendor.given_name = vendor_params[:name]
    @qb_vendor.email_address = vendor_params[:email]
    unless vendor_params[:phone_number].blank?
      phone = Quickbooks::Model::TelephoneNumber.new
      phone.free_form_number = vendor_params[:phone_number]
      @qb_vendor.mobile_phone = phone
    end
    @qb_vendor = @vendor_service.create(@qb_vendor)

    respond_to do |format|
      if @qb_vendor.present?
        format.html { redirect_to vendor_path(@qb_vendor.id), notice: 'Vendor was successfully created.' }
        format.json { render :show, status: :created, location: vendor_path(@qb_vendor.id) }
      else
        format.html { render :new }
        format.json { render json: @vendor.errors, status: :unprocessable_entity }
      end
    end
  end

  def update_qb
    @qb_vendor.display_name = vendor_params[:name]
    @qb_vendor.email_address = vendor_params[:email] unless vendor_params[:email].blank?
    unless vendor_params[:phone_number].blank?
      phone = Quickbooks::Model::TelephoneNumber.new
      phone.free_form_number = vendor_params[:phone_number]
      @qb_vendor.mobile_phone = phone
    end
    @qb_vendor = @vendor_service.update(@qb_vendor)
    
    respond_to do |format|
      if @qb_vendor.present?
        format.html { redirect_to vendor_path(@qb_vendor.id), notice: 'Vendor was successfully updated.' }
        format.json { render :show, status: :ok, location: vendor_path(@qb_vendor.id) }
      else
        format.html { render :edit }
        format.json { render json: @vendor.errors, status: :unprocessable_entity }
      end
    end
  end
  
  # PATCH/PUT /vendors/1
  # PATCH/PUT /vendors/1.json
  def update
    respond_to do |format|
      if @vendor.update(vendor_params)
        format.html { redirect_to @vendor, notice: 'Vendor was successfully updated.' }
        format.json { render :show, status: :ok, location: @vendor }
      else
        format.html { render :edit }
        format.json { render json: @vendor.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /vendors/1
  # DELETE /vendors/1.json
  def destroy
    @vendor.destroy
    respond_to do |format|
      format.html { redirect_to vendors_url, notice: 'Vendor was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  private
    def set_vendor_service
      oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, session[:token], session[:secret])
      @vendor_service = Quickbooks::Service::Vendor.new
      @vendor_service.access_token = oauth_client
      @vendor_service.company_id = session[:realm_id]
    end
  
    # Use callbacks to share common setup or constraints between actions.
    def set_vendor
      #@vendor = Vendor.find(params[:id])
      @qb_vendor = @vendor_service.fetch_by_id(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def vendor_params
      # order matters here in that to have access to model attributes in uploader methods, they need to show up before the file param in this permitted_params list 
      params.require(:vendor).permit(:name, :email, :phone_number)
    end
end
