class PurchasesController < ApplicationController
  before_filter :authenticate_user!
#  load_and_authorize_resource

  before_action :set_purchase_service, only: [:index, :show, :create, :edit, :update, :update_qb, :destroy]
  before_action :set_vendor_service, only: [:index, :show, :create, :edit, :update]
  before_action :set_purchase, only: [:show, :edit, :update, :update_qb, :destroy]

  # GET /purchases
  # GET /purchases.json
  def index
    @purchases = @purchase_service.query(nil, :per_page => 20)
  end

  # GET /purchases/1
  # GET /purchases/1.json
  def show
    
  end

  # GET /purchases/new
  def new
  end

  # GET /purchases/1/edit
  def edit
  end
  
  def create_qb
    @qb_purchase = Quickbooks::Model::Purchase.new
    @qb_purchase.given_name = purchase_params[:name]
    @qb_purchase.email_address = purchase_params[:email]
    unless purchase_params[:phone_number].blank?
      phone = Quickbooks::Model::TelephoneNumber.new
      phone.free_form_number = purchase_params[:phone_number]
      @qb_purchase.mobile_phone = phone
    end
    @qb_purchase = @purchase_service.create(purchase)

    respond_to do |format|
      if @qb_purchase.present?
        format.html { redirect_to purchase_path(@qb_purchase.id), notice: 'Purchase was successfully created.' }
        format.json { render :show, status: :created, location: purchase_path(@qb_purchase.id) }
      else
        format.html { render :new }
        format.json { render json: @purchase.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /purchases
  # POST /purchases.json
  def create
    @qb_purchase = Quickbooks::Model::Purchase.new
    @qb_purchase.given_name = purchase_params[:name]
    @qb_purchase.email_address = purchase_params[:email]
    unless purchase_params[:phone_number].blank?
      phone = Quickbooks::Model::TelephoneNumber.new
      phone.free_form_number = purchase_params[:phone_number]
      @qb_purchase.mobile_phone = phone
    end
    @qb_purchase = @purchase_service.create(@qb_purchase)

    respond_to do |format|
      if @qb_purchase.present?
        format.html { redirect_to purchase_path(@qb_purchase.id), notice: 'Purchase was successfully created.' }
        format.json { render :show, status: :created, location: purchase_path(@qb_purchase.id) }
      else
        format.html { render :new }
        format.json { render json: @purchase.errors, status: :unprocessable_entity }
      end
    end
  end

  def update_qb
    @qb_purchase.display_name = purchase_params[:name]
    @qb_purchase.email_address = purchase_params[:email] unless purchase_params[:email].blank?
    unless purchase_params[:phone_number].blank?
      phone = Quickbooks::Model::TelephoneNumber.new
      phone.free_form_number = purchase_params[:phone_number]
      @qb_purchase.mobile_phone = phone
    end
    @qb_purchase = @purchase_service.update(@qb_purchase)
    
    respond_to do |format|
      if @qb_purchase.present?
        format.html { redirect_to purchase_path(@qb_purchase.id), notice: 'Purchase was successfully updated.' }
        format.json { render :show, status: :ok, location: purchase_path(@qb_purchase.id) }
      else
        format.html { render :edit }
        format.json { render json: @purchase.errors, status: :unprocessable_entity }
      end
    end
  end
  
  # PATCH/PUT /purchases/1
  # PATCH/PUT /purchases/1.json
  def update
    respond_to do |format|
      if @purchase.update(purchase_params)
        format.html { redirect_to @purchase, notice: 'Purchase was successfully updated.' }
        format.json { render :show, status: :ok, location: @purchase }
      else
        format.html { render :edit }
        format.json { render json: @purchase.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /purchases/1
  # DELETE /purchases/1.json
  def destroy
    @purchase.destroy
    respond_to do |format|
      format.html { redirect_to purchases_url, notice: 'Purchase was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  private
    def set_purchase_service
      oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, session[:token], session[:secret])
      @purchase_service = Quickbooks::Service::Purchase.new
      @purchase_service.access_token = oauth_client
      @purchase_service.company_id = current_company_id
    end
    
    def set_vendor_service
      oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, session[:token], session[:secret])
      @vendor_service = Quickbooks::Service::Vendor.new
      @vendor_service.access_token = oauth_client
      @vendor_service.company_id = current_company_id
    end
  
    # Use callbacks to share common setup or constraints between actions.
    def set_purchase
      #@purchase = Purchase.find(params[:id])
      @qb_purchase = @purchase_service.fetch_by_id(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def purchase_params
      # order matters here in that to have access to model attributes in uploader methods, they need to show up before the file param in this permitted_params list 
      params.require(:purchase).permit(:name, :email, :phone_number)
    end
end
