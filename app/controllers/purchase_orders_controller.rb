class PurchaseOrdersController < ApplicationController
  before_filter :authenticate_user!
#  load_and_authorize_resource

  before_action :set_purchase_order_service, only: [:index, :show, :create, :edit, :update, :update_qb, :destroy]
  before_action :set_vendor_service, only: [:show, :new, :create, :edit, :update]
  before_action :set_item_service, only: [:show, :new, :create, :edit, :line_item_fields]
  before_action :set_bill_service, only: [:show]
  before_action :set_company_service, only: [:show]
  
  before_action :set_purchase_order, only: [:show, :edit, :update, :update_qb, :destroy]

  # GET /purchase_orders
  # GET /purchase_orders.json
  def index
#    query = "Select * From PurchaseOrder Where TxnDate>'#{1.month.ago.strftime("%Y-%m-%d")}'"
    query = "Select * From PurchaseOrder Where TxnDate>'#{1.day.ago.strftime("%Y-%m-%d")}'"
    @open_purchase_orders = @purchase_order_service.query(query).entries.find_all{ |e| e.po_status == 'Open' }
    if @open_purchase_orders.blank? # Get last 10 if none today
      @open_purchase_orders = @purchase_order_service.query(nil, :per_page => 10).entries.find_all{ |e| e.po_status == 'Open' }
    end
    @open_purchase_orders = Kaminari.paginate_array(@open_purchase_orders).page(params[:page]).per(3)
#    @open_purchase_orders = @purchase_order_service.query(nil, :per_page => 1000).entries.find_all{ |e| e.po_status == 'Open' }
#    @closed_purchase_orders = @purchase_order_service.query(nil, :per_page => 20).entries.find_all{ |e| e.po_status == 'Closed' }
    
#    if params[:status] == "Open"
#      @open_purchase_orders = @purchase_order_service.query.entries.find_all{ |e| e.po_status == 'Open' }
##      query = "Select * From PurchaseOrder Where POStatus is not null AND Where POStatus = 'Open'"
##      @purchase_orders = @purchase_order_service.query(query, :per_page => 20)
#    elsif params[:status] == "Closed"
#      @closed_purchase_orders = @purchase_order_service.query.entries.find_all{ |e| e.po_status == 'Closed' }
##      query = "Select * From PurchaseOrder Where POStatus is not null AND  Where POStatus = 'Closed'"
##      @purchase_orders = @purchase_order_service.query(query, :per_page => 20)
#    else
#      @open_purchase_orders = @purchase_order_service.query.entries.find_all{ |e| e.po_status == 'Open' }
##      @purchase_orders = @purchase_order_service.query(nil, :per_page => 20)
#    end
    
  end

  # GET /purchase_orders/1
  # GET /purchase_orders/1.json
  def show
    @vendor = @vendor_service.fetch_by_id(@purchase_order.vendor_ref)
    @doc_number = @purchase_order.doc_number
    
    respond_to do |format|
      format.html do
        @images = Image.where(ticket_nbr: @doc_number)
        @bill = @bill_service.query.entries.find{ |b| b.doc_number == @doc_number } if @purchase_order.po_status == "Closed"
      end
      format.pdf do
        @signature = Image.where(ticket_nbr: @doc_number, event_code: "SIG").last
        render pdf: "file_name",
        :layout => 'pdf.html.haml'
      end
    end
  end

  # GET /purchase_orders/new
  def new
#    @vendors = @vendor_service.query(nil, :per_page => 1000)
    
#    query = "Select * From Item Where Type = 'Inventory'"
#    @items = @item_service.query(query, :per_page => 1000)
    
    @items = @item_service.query(nil, :per_page => 1000)
  end

  # GET /purchase_orders/1/edit
  def edit
#    @vendors = @vendor_service.query(nil, :per_page => 1000)
    @vendor = @vendor_service.fetch_by_id(@purchase_order.vendor_ref)
    @doc_number = @purchase_order.doc_number
    
#    query = "Select * From Item Where Type = 'Inventory'"
#    @items = @item_service.query(query, :per_page => 1000)
    
#    @items = @item_service.query(nil, :per_page => 1000)
    @images = Image.where(ticket_nbr: @doc_number)
  end
  
  # POST /purchase_orders
  # POST /purchase_orders.json
  def create
    #vendor = @vendor_service.fetch_by_id(purchase_order_params[:vendor])

    @purchase_order = Quickbooks::Model::PurchaseOrder.new
    @purchase_order.vendor_id = purchase_order_params[:vendor]
    @purchase_order.po_status = purchase_order_params[:po_status]
    
    purchase_order_params[:line_items].each do |line_item|
      item_based_expense_line_detail = Quickbooks::Model::ItemBasedExpenseLineDetail.new
      item_based_expense_line_detail.unit_price = line_item[:rate]
      item_based_expense_line_detail.quantity = line_item[:quantity]
      item_based_expense_line_detail.item_id= line_item[:item]

      purchase_line_item = Quickbooks::Model::PurchaseLineItem.new
      purchase_line_item.detail_type = "ItemBasedExpenseLineDetail"
      purchase_line_item.item_based_expense_line_detail = item_based_expense_line_detail
      purchase_line_item.amount = line_item[:amount]
#      purchase_line_item.description = line_item[:description]
      purchase_line_item.description = "#{line_item[:gross]} - #{line_item[:tare]}" unless line_item[:gross].blank? or line_item[:tare].blank?
      @purchase_order.line_items.push(purchase_line_item)
    end
    
    @purchase_order = @purchase_order_service.create(@purchase_order)

    respond_to do |format|
      if @purchase_order.present?
#        format.html { redirect_to purchase_order_path(@purchase_order.id), notice: 'Ticket was successfully created.' }
        format.html { redirect_to edit_purchase_order_path(@purchase_order.id) }
        format.json { render :show, status: :created, location: purchase_order_path(@purchase_order.id) }
      else
        format.html { render :new }
        format.json { render json: @purchase_order.errors, status: :unprocessable_entity }
      end
    end
  end

  def update_qb
    @purchase_order.vendor_id = purchase_order_params[:vendor]
    @purchase_order.po_status = purchase_order_params[:po_status]
    @purchase_order.line_items.clear
    
    purchase_order_params[:line_items].each do |line_item|
      item_based_expense_line_detail = Quickbooks::Model::ItemBasedExpenseLineDetail.new
      item_based_expense_line_detail.unit_price = line_item[:rate]
      item_based_expense_line_detail.quantity = line_item[:quantity]
      item_based_expense_line_detail.item_id= line_item[:item]

      purchase_line_item = Quickbooks::Model::PurchaseLineItem.new
      purchase_line_item.detail_type = "ItemBasedExpenseLineDetail"
      purchase_line_item.item_based_expense_line_detail = item_based_expense_line_detail
      purchase_line_item.amount = line_item[:amount]
#      purchase_line_item.description = line_item[:description]
      unless (line_item[:gross].blank? and line_item[:tare].blank?)
        purchase_line_item.description = "#{line_item[:gross]} - #{line_item[:tare]}"
      else
        purchase_line_item.description = line_item[:description]
      end
      @purchase_order.line_items.push(purchase_line_item)
    end
    
    @purchase_order = @purchase_order_service.update(@purchase_order)
    
    respond_to do |format|
      if @purchase_order.present?
#        format.html { redirect_to purchase_order_path(@purchase_order.id), notice: 'Ticket was successfully updated.' }
        format.html { 
          if params[:close_ticket]
            redirect_to new_bill_path(purchase_order_id: @purchase_order.id, close_ticket: true), notice: 'Closing ticket, please wait ...'
          elsif params[:save_and_print]
#            redirect_to purchase_order_path(@purchase_order.id, format: 'pdf')
            redirect_to purchase_orders_path, notice: "Ticket was saved.  Click #{view_context.link_to 'here', purchase_order_path(@purchase_order.id, format: 'pdf'), target: '_blank'} to print."
            #"Ticket was saved. Click <a href='#{purchase_order_path(@purchase_order.id, format: 'pdf')}'>here</a> to print."
          else
            redirect_to purchase_orders_path
          end
          }
        format.json { render :show, status: :ok, location: purchase_order_path(@purchase_order.id) }
      else
        format.html { render :edit }
        format.json { render json: @purchase_order.errors, status: :unprocessable_entity }
      end
    end
  end
  
  # PATCH/PUT /purchase_orders/1
  # PATCH/PUT /purchase_orders/1.json
  def update
    respond_to do |format|
      if @purchase_order.update(purchase_order_params)
        format.html { redirect_to @purchase_order, notice: 'PurchaseOrder was successfully updated.' }
        format.json { render :show, status: :ok, location: @purchase_order }
      else
        format.html { render :edit }
        format.json { render json: @purchase_order.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def line_item_fields
    @items = @item_service.query(nil, :per_page => 1000)
#    query = "Select * From Item Where Type = 'Inventory'"
#    @items = @item_service.query(query, :per_page => 1000)
    respond_to do |format|
      format.js
    end
  end

  # DELETE /purchase_orders/1
  # DELETE /purchase_orders/1.json
  def destroy
    @purchase_order.destroy
    respond_to do |format|
      format.html { redirect_to purchase_orders_url, notice: 'PurchaseOrder was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  private
    def set_purchase_order_service
      oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, session[:token], session[:secret])
      @purchase_order_service = Quickbooks::Service::PurchaseOrder.new
      @purchase_order_service.access_token = oauth_client
      @purchase_order_service.company_id = session[:realm_id]
    end
    
    def set_vendor_service
      oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, session[:token], session[:secret])
      @vendor_service = Quickbooks::Service::Vendor.new
      @vendor_service.access_token = oauth_client
      @vendor_service.company_id = session[:realm_id]
    end
    
    def set_item_service
      oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, session[:token], session[:secret])
      @item_service = Quickbooks::Service::Item.new
      @item_service.access_token = oauth_client
      @item_service.company_id = session[:realm_id]
    end
    
    def set_bill_service
      oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, session[:token], session[:secret])
      @bill_service = Quickbooks::Service::Bill.new
      @bill_service.access_token = oauth_client
      @bill_service.company_id = session[:realm_id]
    end
    
    def set_company_service
      oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, session[:token], session[:secret])
      @company_info_service = Quickbooks::Service::CompanyInfo.new
      @company_info_service.access_token = oauth_client
      @company_info_service.company_id = session[:realm_id]
      @company_info = @company_info_service.fetch_by_id(session[:realm_id])
    end
    
    # Use callbacks to share common setup or constraints between actions.
    def set_purchase_order
      #@purchase_order = PurchaseOrder.find(params[:id])
      @purchase_order = @purchase_order_service.fetch_by_id(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def purchase_order_params
      # order matters here in that to have access to model attributes in uploader methods, they need to show up before the file param in this permitted_params list 
      params.require(:purchase_order).permit(:vendor, :po_status, line_items: [:item, :description, :gross, :tare, :quantity, :rate, :amount])
    end
    
#    def line_params
#      # order matters here in that to have access to model attributes in uploader methods, they need to show up before the file param in this permitted_params list 
##      params.require(:line).permit("item")
#      params.permit("item")
#    end
end
