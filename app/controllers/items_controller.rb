class ItemsController < ApplicationController
  before_filter :authenticate_user!
#  load_and_authorize_resource

  before_action :set_oauth_client
  before_action :set_item_service, only: [:index, :show, :create, :edit, :update, :update_qb, :destroy]
  before_action :set_vendor_service, only: [:index, :show, :create, :edit, :update]
  before_action :set_account_service, only: [:new, :edit]
  before_action :set_item, only: [:show, :edit, :update, :update_qb, :destroy]

  # GET /items
  # GET /items.json
  def index
#    query = "Select * From Item Where Type = 'Inventory'"
#    @items = @item_service.query(query, :per_page => 1000)
    unless params[:search].blank?
      query = "SELECT * FROM Item WHERE Name LIKE '%#{params[:search].gsub("'"){"\\'"}}%'"
      @items = @item_service.query(query, :per_page => 1000)
    else
      @items = @item_service.query(nil, :per_page => 1000)
    end
    
    respond_to do |format|
      format.html {
        @items = Kaminari.paginate_array(@items.entries).page(params[:page]).per(5)
      }
      format.js {
        @items = Kaminari.paginate_array(@items.entries).page(params[:page]).per(5)
      }
      format.json {
        render json: @items.map{|v| v.display_name}
      }
    end
  end

  # GET /items/1
  # GET /items/1.json
  def show
    respond_to do |format|
      format.html {}
#      format.json { render json: @item.unit_price }
#      format.json {render json: {"name" => @item.name, "description" => @item.description, "unit_price" => @item.unit_price} } 
      format.json {render json: {"name" => @item.name, "purchase_desc" => @item.purchase_desc, "purchase_cost" => @item.purchase_cost, "unit_price" => @item.unit_price} } 
    end
  end

  # GET /items/new
  def new
    @accounts = @account_service.query(nil, :per_page => 1000)
  end

  # GET /items/1/edit
  def edit
    @accounts = @account_service.query(nil, :per_page => 1000)
  end
  
  def create
    @item = Quickbooks::Model::Item.new
    @item.name = item_params[:name]
    @item.purchase_desc = item_params[:purchase_desc]
    @item.purchase_cost = item_params[:purchase_cost]
    @item.expense_account_id = item_params[:expense_account_ref]
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
    @item.name = item_params[:name]
    @item.purchase_desc = item_params[:purchase_desc]
    @item.purchase_cost = item_params[:purchase_cost]
    @item.expense_account_id = item_params[:expense_account_ref]
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
    def set_oauth_client
      @oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, current_user.qbo_access_credential.access_token, current_user.qbo_access_credential.access_secret)
    end
    
    def set_item_service
#      oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, session[:token], session[:secret])
      @item_service = Quickbooks::Service::Item.new
      @item_service.access_token = @oauth_client
      @item_service.company_id = current_company_id
    end
    
    def set_vendor_service
#      oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, session[:token], session[:secret])
      @vendor_service = Quickbooks::Service::Vendor.new
      @vendor_service.access_token = @oauth_client
      @vendor_service.company_id = current_company_id
    end
    
    def set_account_service
#      oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, session[:token], session[:secret])
      @account_service = Quickbooks::Service::Account.new
      @account_service.access_token = @oauth_client
      @account_service.company_id = current_company_id
    end
  
    # Use callbacks to share common setup or constraints between actions.
    def set_item
      #@item = Item.find(params[:id])
      @item = @item_service.fetch_by_id(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def item_params
      # order matters here in that to have access to model attributes in uploader methods, they need to show up before the file param in this permitted_params list 
      params.require(:item).permit(:name, :description, :purchase_cost, :expense_account_ref)
    end
end
