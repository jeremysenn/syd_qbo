class ItemsController < ApplicationController
  before_filter :authenticate_user!
#  load_and_authorize_resource

  before_action :set_item_service, only: [:index, :show, :create, :edit, :update, :update_qb, :destroy]
  before_action :set_vendor_service, only: [:index, :show, :create, :edit, :update]
  before_action :set_item, only: [:show, :edit, :update, :update_qb, :destroy]

  # GET /items
  # GET /items.json
  def index
    @items = @item_service.query(nil, :per_page => 1000)
    
#    query = "Select * From Item Where Type = 'Inventory'"
#    @items = @item_service.query(query, :per_page => 1000)
    
    
  end

  # GET /items/1
  # GET /items/1.json
  def show
    respond_to do |format|
      format.html {}
#      format.json { render json: @item.unit_price }
      format.json {render json: {"name" => @item.name, "description" => @item.description, "unit_price" => @item.unit_price} } 
    end
  end

  # GET /items/new
  def new
  end

  # GET /items/1/edit
  def edit
  end
  
  def create_qb
    @item = Quickbooks::Model::Item.new
    @item.given_name = item_params[:name]
    @item.email_address = item_params[:email]
    unless item_params[:phone_number].blank?
      phone = Quickbooks::Model::TelephoneNumber.new
      phone.free_form_number = item_params[:phone_number]
      @item.mobile_phone = phone
    end
    @item = @item_service.create(item)

    respond_to do |format|
      if @item.present?
        format.html { redirect_to item_path(@item.id), notice: 'Item was successfully created.' }
        format.json { render :show, status: :created, location: item_path(@item.id) }
      else
        format.html { render :new }
        format.json { render json: @item.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /items
  # POST /items.json
  def create
    @item = Quickbooks::Model::Item.new
    @item.given_name = item_params[:name]
    @item.email_address = item_params[:email]
    unless item_params[:phone_number].blank?
      phone = Quickbooks::Model::TelephoneNumber.new
      phone.free_form_number = item_params[:phone_number]
      @item.mobile_phone = phone
    end
    @item = @item_service.create(@item)

    respond_to do |format|
      if @item.present?
        format.html { redirect_to item_path(@item.id), notice: 'Item was successfully created.' }
        format.json { render :show, status: :created, location: item_path(@item.id) }
      else
        format.html { render :new }
        format.json { render json: @item.errors, status: :unprocessable_entity }
      end
    end
  end

  def update_qb
    @item.display_name = item_params[:name]
    @item.email_address = item_params[:email] unless item_params[:email].blank?
    unless item_params[:phone_number].blank?
      phone = Quickbooks::Model::TelephoneNumber.new
      phone.free_form_number = item_params[:phone_number]
      @item.mobile_phone = phone
    end
    @item = @item_service.update(@item)
    
    respond_to do |format|
      if @item.present?
        format.html { redirect_to item_path(@item.id), notice: 'Item was successfully updated.' }
        format.json { render :show, status: :ok, location: item_path(@item.id) }
      else
        format.html { render :edit }
        format.json { render json: @item.errors, status: :unprocessable_entity }
      end
    end
  end
  
  # PATCH/PUT /items/1
  # PATCH/PUT /items/1.json
  def update
    respond_to do |format|
      if @item.update(item_params)
        format.html { redirect_to @item, notice: 'Item was successfully updated.' }
        format.json { render :show, status: :ok, location: @item }
      else
        format.html { render :edit }
        format.json { render json: @item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /items/1
  # DELETE /items/1.json
  def destroy
    @item.destroy
    respond_to do |format|
      format.html { redirect_to items_url, notice: 'Item was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  private
    def set_item_service
      oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, session[:token], session[:secret])
      @item_service = Quickbooks::Service::Item.new
      @item_service.access_token = oauth_client
      @item_service.company_id = session[:realm_id]
    end
    
    def set_vendor_service
      oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, session[:token], session[:secret])
      @vendor_service = Quickbooks::Service::Vendor.new
      @vendor_service.access_token = oauth_client
      @vendor_service.company_id = session[:realm_id]
    end
  
    # Use callbacks to share common setup or constraints between actions.
    def set_item
      #@item = Item.find(params[:id])
      @item = @item_service.fetch_by_id(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def item_params
      # order matters here in that to have access to model attributes in uploader methods, they need to show up before the file param in this permitted_params list 
      params.require(:item).permit(:name, :email, :phone_number)
    end
end
