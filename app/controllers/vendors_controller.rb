class VendorsController < ApplicationController
  before_filter :authenticate_user!
#  load_and_authorize_resource
  
  before_action :set_oauth_client
  before_action :set_vendor_service, only: [:index, :show, :create, :edit, :update, :update_qb, :destroy]
  before_action :set_item_service, only: [:index, :show, :edit]
  before_action :set_vendor, only: [:show, :edit, :update, :update_qb, :destroy]

  # GET /vendors
  # GET /vendors.json
  def index
#    @items = @item_service.query(nil, :per_page => 1000)
    first_item_query = "select * from Item maxresults 1"
    @first_items = @item_service.query(first_item_query, :per_page => 1)
    unless params[:search].blank?
      #query = "SELECT * FROM Vendor WHERE DisplayName LIKE #{params[:search]};"
      query = "SELECT * FROM Vendor WHERE DisplayName LIKE '%#{params[:search].gsub("'"){"\\'"}}%'"
      @vendors = @vendor_service.query(query, :per_page => 1000)
    else
      @vendors = @vendor_service.query(nil, :per_page => 1000)
    end
    respond_to do |format|
      format.html {
        @vendors = Kaminari.paginate_array(@vendors.entries).page(params[:page]).per(5)
      }
      format.js {
        @vendors = Kaminari.paginate_array(@vendors.entries).page(params[:page]).per(5)
      }
      format.json {
        render json: @vendors.map{|v| v.display_name}
      }
    end
  end

  # GET /vendors/1
  # GET /vendors/1.json
  def show
#    @vendors = @vendor_service.query(nil, :per_page => 1000)
#    @items = @item_service.query(nil, :per_page => 1000)
    first_item_query = "select * from Item maxresults 1"
    @first_items = @item_service.query(first_item_query, :per_page => 1)
    @cust_pics = CustPic.where(cust_nbr: @vendor.id, location: current_company_id)
  end

  # GET /vendors/new
  def new
  end

  # GET /vendors/1/edit
  def edit
#    @vendors = @vendor_service.query(nil, :per_page => 1000)
#    @items = @item_service.query(nil, :per_page => 1000)
    @cust_pics = CustPic.where(cust_nbr: @vendor.id, location: current_company_id)
  end
  
  # POST /vendors
  # POST /vendors.json
  def create
    @vendor = Quickbooks::Model::Vendor.new
    @vendor.given_name = vendor_params[:given_name] unless vendor_params[:given_name].blank?
    @vendor.family_name = vendor_params[:family_name] unless vendor_params[:family_name].blank?
    @vendor.company_name = vendor_params[:company_name] unless vendor_params[:company_name].blank?
    @vendor.display_name = vendor_params[:display_name] unless vendor_params[:display_name].blank?
    unless vendor_params[:billing_address].blank?
      billing_address = Quickbooks::Model::PhysicalAddress.new
      billing_address.line1 = vendor_params[:billing_address][:line1]
      billing_address.city = vendor_params[:billing_address][:city]
      billing_address.country_sub_division_code = vendor_params[:billing_address][:country_sub_division_code]
      billing_address.postal_code = vendor_params[:billing_address][:postal_code]
      @vendor.billing_address = billing_address
    end
    @vendor.email_address = vendor_params[:email] unless vendor_params[:email].blank?
    unless vendor_params[:phone_number].blank?
      phone = Quickbooks::Model::TelephoneNumber.new
      phone.free_form_number = vendor_params[:phone_number]
      @vendor.primary_phone = phone
    end
    begin
      @vendor = @vendor_service.create(@vendor)
    rescue Quickbooks::IntuitRequestException => e
      flash.now[:error] = e
      logger.error e
    rescue => e
      logger.error e
    ensure
#      logger.debug "ensure block"
    end

    respond_to do |format|
      if @vendor.id.present?
        
        # Update the all_vendors rails cache
        vendors = @vendor_service.query(nil, :per_page => 1000)
        Rails.cache.delete("all_vendors")
        Rails.cache.fetch("all_vendors") {Hash[vendors.map{ |v| [v.display_name,v.id] }]}
        
        format.html { 
          if params[:vendor_quick_create]
            redirect_to :back, notice: 'Vendor was successfully created.'
          elsif params[:vendor_quick_create_from_ticket]
            redirect_to new_purchase_order_path(vendor_id: @vendor.id), notice: 'Vendor was successfully created.'
          else
            redirect_to vendor_path(@vendor.id), notice: 'Vendor was successfully created.'
          end
          }
#        format.html { redirect_to vendor_path(@vendor.id), notice: 'Vendor was successfully created.' }
        format.json { render :show, status: :created, location: vendor_path(@vendor.id) }
      else
        format.html { render :new }
        format.json { render json: @vendor.errors, status: :unprocessable_entity }
      end
    end
  end

  def update_qb
    @vendor.given_name = vendor_params[:given_name]
    @vendor.family_name = vendor_params[:family_name]
    @vendor.company_name = vendor_params[:company_name]
    @vendor.display_name = vendor_params[:display_name]
    
    unless vendor_params[:billing_address].blank?
      billing_address = Quickbooks::Model::PhysicalAddress.new
      billing_address.line1 = vendor_params[:billing_address][:line1]
      billing_address.city = vendor_params[:billing_address][:city]
      billing_address.country_sub_division_code = vendor_params[:billing_address][:country_sub_division_code]
      billing_address.postal_code = vendor_params[:billing_address][:postal_code]
      @vendor.billing_address = billing_address
    end
    @vendor.email_address = vendor_params[:email] unless vendor_params[:email].blank?
    
    unless vendor_params[:phone_number].blank?
      phone = Quickbooks::Model::TelephoneNumber.new
      phone.free_form_number = vendor_params[:phone_number]
      @vendor.primary_phone = phone
    end
    begin
      @vendor = @vendor_service.update(@vendor)
    rescue Quickbooks::IntuitRequestException => e
      flash[:error] = e
      logger.error e
    rescue => e
      logger.error e
    ensure
#      logger.debug "ensure block"
    end
    
    respond_to do |format|
      if @vendor.present?
        format.html { redirect_to vendor_path(@vendor.id) }
        format.json { render :show, status: :ok, location: vendor_path(@vendor.id) }
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
    def set_oauth_client
      @oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, current_user.qbo_access_credential.access_token, current_user.qbo_access_credential.access_secret)
    end
  
    def set_vendor_service
#      oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, session[:token], session[:secret])
      @vendor_service = Quickbooks::Service::Vendor.new
      @vendor_service.access_token = @oauth_client
      @vendor_service.company_id = current_company_id
    end
    
    def set_item_service
#      oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, session[:token], session[:secret])
      @item_service = Quickbooks::Service::Item.new
      @item_service.access_token = @oauth_client
      @item_service.company_id = current_company_id
    end
  
    # Use callbacks to share common setup or constraints between actions.
    def set_vendor
      #@vendor = Vendor.find(params[:id])
      @vendor = @vendor_service.fetch_by_id(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def vendor_params
      # order matters here in that to have access to model attributes in uploader methods, they need to show up before the file param in this permitted_params list 
      params.require(:vendor).permit(:given_name, :family_name, :company_name, :display_name, :email, :phone_number, billing_address: [:line1, :city, :country_sub_division_code, :postal_code])
    end
end
