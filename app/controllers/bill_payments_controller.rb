class BillPaymentsController < ApplicationController
  before_filter :authenticate_user!
#  load_and_authorize_resource

  before_action :set_oauth_client
  before_action :set_bill_payment_service, only: [:index, :show, :create, :edit, :update, :update_qb, :destroy]
  before_action :set_vendor_service, only: [:index, :show, :new, :create, :edit, :update]
  before_action :set_item_service, only: [:index, :show, :new, :create, :edit, :line_item_fields]
  before_action :set_purchase_order_service, only: [:new, :create, :edit, :update, :update_qb, :destroy]
  before_action :set_bill_service, only: [:show, :new, :create, :update_qb]
  before_action :set_account_service, only: [:new, :create]
  before_action :set_company_service, only: [:show]
  
  before_action :set_bill_payment, only: [:show, :edit, :update, :update_qb, :destroy]

  # GET /bill_payments
  # GET /bill_payments.json
  def index
#    @vendors = @vendor_service.query(nil, :per_page => 1000)
#    @items = @item_service.query(nil, :per_page => 1000)
#    query = "Select * From BillPayment Where TxnDate>'#{1.month.ago.strftime("%Y-%m-%d")}'"
    @bill_payments = @bill_payment_service.query(nil, :per_page => 30).entries
    @bill_payments = Kaminari.paginate_array(@bill_payments).page(params[:page]).per(3)
  end

  # GET /bill_payments/1
  # GET /bill_payments/1.json
  def show
#    @vendors = @vendor_service.query(nil, :per_page => 1000)
#    @items = @item_service.query(nil, :per_page => 1000)
    @doc_number = @bill_payment.doc_number
    @bill = @bill_service.query.entries.find{ |b| b.doc_number == @doc_number }
    
    respond_to do |format|
      format.html do
        @images = Image.where(ticket_nbr: @doc_number)
      end
      format.pdf do
        @signature_image = Image.where(ticket_nbr: @doc_number, location: current_company_id, event_code: "SIGNATURE CAPTURE").last
        @finger_print_image = Image.where(ticket_nbr: @doc_number, location: current_company_id, event_code: "Finger Print").last
        render pdf: "BillPayment#{@doc_number}",
#        :page_width => 4,
        :layout => 'pdf.html.haml',
        :zoom => 1.75,
        :save_to_file => Rails.root.join('pdfs', "#{current_company_id}BillPayment#{@doc_number}.pdf")
        unless current_user.printer_devices.blank?
          current_user.printer_devices.last.call_printer_for_bill_payment_pdf(Base64.encode64(File.binread(Rails.root.join('pdfs', "#{current_company_id}BillPayment#{@doc_number}.pdf"))))
        end
        # Remove the temporary pdf file that was created above
        FileUtils.remove(Rails.root.join('pdfs', "#{current_company_id}BillPayment#{@doc_number}.pdf"))
      end
    end
    
#    @images = Image.where(ticket_nbr: @doc_number, location: current_user.location)
  end

  # GET /bill_payments/new
  def new
#    @vendors = @vendor_service.query(nil, :per_page => 1000)
    @bill= @bill_service.fetch_by_id(params[:bill_id])
    
    query_banks = "Select * from Account Where AccountType = 'Bank'"
    query_credit_cards = "Select * from Account Where AccountType = 'Credit Card'"
#    @accounts = @account_service.query(query, :per_page => 1000)
    @bank_accounts = @account_service.query(query_banks, :per_page => 1000)
    @credit_card_accounts = @account_service.query(query_credit_cards, :per_page => 1000)
    @accounts = []
    @bank_accounts.each do |bank_account|
      @accounts.push(bank_account)
    end
    @credit_card_accounts.each do |credit_card_account|
      @accounts.push(credit_card_account)
    end
  end

  # GET /bill_payments/1/edit
  def edit
    @vendors = @vendor_service.query(nil, :per_page => 1000)
    @vendor = @vendor_service.fetch_by_id(@bill_payment.vendor_ref)
    
#    query = "Select * From Item Where Type = 'Inventory'"
#    @items = @item_service.query(query, :per_page => 1000)
    
    @items = @item_service.query(nil, :per_page => 1000)
  end
  
  # POST /bill_payments
  # POST /bill_payments.json
  def create
    @bill = @bill_service.fetch_by_id(params[:bill_id])
    @bill_payment = Quickbooks::Model::BillPayment.new
    @bill_payment.vendor_id = @bill.vendor_ref
    @bill_payment.doc_number = bill_payment_params[:doc_number]
    @bill_payment.total = bill_payment_params[:total]
    
    @account = @account_service.fetch_by_id(bill_payment_params[:pay_account])
#    @bill_payment.ap_account_id = @account.id
    if @account.account_type == 'Bank'
      @bill_payment.pay_type = 'Check'
      bill_payment_check = Quickbooks::Model::BillPaymentCheck.new
      bill_payment_check.bank_account_id = @account.id
#      bill_payment_check.bank_account_ref.name = @account.name
      @bill_payment.check_payment = bill_payment_check
    elsif @account.account_type == 'Credit Card'
      @bill_payment.pay_type = 'Credit Card'
      bill_payment_credit_card = Quickbooks::Model::BillPaymentCreditCard.new
      bill_payment_credit_card.cc_account_id = @account.id
#      bill_payment_credit_card.bank_account_ref.value = @account.name
      @bill_payment.credit_card_payment = bill_payment_credit_card
    end
    
    linked_transaction = Quickbooks::Model::LinkedTransaction.new
    linked_transaction.txn_id = @bill.id
    linked_transaction.txn_type = "Bill"
    
    bill_payment_line_item = Quickbooks::Model::BillPaymentLineItem.new
#    bill_payment_line_item.detail_type = "ItemBasedExpenseLineDetail"
    bill_payment_line_item.amount = @bill_payment.total
    bill_payment_line_item.linked_transactions = []
    bill_payment_line_item.linked_transactions.push(linked_transaction)
    
    @bill_payment.line_items.push(bill_payment_line_item)
    
    @bill_payment = @bill_payment_service.create(@bill_payment)

    respond_to do |format|
      if @bill_payment.present?
#        @bill.balance = @bill.balance - bill_payment_params[:total].to_f
#        @bill_service.update(@bill)
        format.html { redirect_to bill_payment_path(@bill_payment.id), notice: 'Payment was successfully created.' }
#        format.html { redirect_to bill_payments_path, notice: 'Payment was successfully created.' }
#        format.html { redirect_to bills_path }
        format.json { render :show, status: :created, location: bill_payment_path(@bill_payment.id) }
      else
        format.html { render :new }
        format.json { render json: @bill_payment.errors, status: :unprocessable_entity }
      end
    end
  end

  def update_qb
    @bill_payment.vendor_id = bill_payment_params[:vendor]
    @bill_payment.doc_number = bill_payment_params[:doc_number]
    @bill_payment.line_items.clear
    
    bill_payment_params[:line_items].each do |line_item|
      item_based_expense_line_detail = Quickbooks::Model::ItemBasedExpenseLineDetail.new
      item_based_expense_line_detail.unit_price = line_item[:rate]
      item_based_expense_line_detail.quantity = line_item[:quantity]
      item_based_expense_line_detail.item_id= line_item[:item]

      bill_payment_line_item = Quickbooks::Model::BillPaymentLineItem.new
      bill_payment_line_item.detail_type = "ItemBasedExpenseLineDetail"
      bill_payment_line_item.item_based_expense_line_detail = item_based_expense_line_detail
      bill_payment_line_item.amount = line_item[:amount]
      bill_payment_line_item.description = "Gross: #{line_item[:gross]}, Tare: #{line_item[:tare]}" unless (line_item[:gross].blank? or line_item[:tare].blank?)
      @bill_payment.line_items.push(bill_payment_line_item)
    end
    
    @bill_payment = @bill_payment_service.update(@bill_payment)
    
    respond_to do |format|
      if @bill_payment.present?
        format.html { redirect_to bill_payment_path(@bill_payment.id) }
        format.json { render :show, status: :ok, location: bill_payment_path(@bill_payment.id) }
      else
        format.html { render :edit }
        format.json { render json: @bill_payment.errors, status: :unprocessable_entity }
      end
    end
  end
  
  # PATCH/PUT /bill_payments/1
  # PATCH/PUT /bill_payments/1.json
  def update
    respond_to do |format|
      if @bill_payment.update(bill_payment_params)
        format.html { redirect_to @bill_payment, notice: 'BillPayment was successfully updated.' }
        format.json { render :show, status: :ok, location: @bill_payment }
      else
        format.html { render :edit }
        format.json { render json: @bill_payment.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def line_item_fields
    @items = @item_service.query(nil, :per_page => 1000)
    respond_to do |format|
      format.js
    end
  end

  # DELETE /bill_payments/1
  # DELETE /bill_payments/1.json
  def destroy
    @bill_payment.destroy
    respond_to do |format|
      format.html { redirect_to bill_payments_url, notice: 'BillPayment was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  private
    def set_oauth_client
      @oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, current_user.qbo_access_credential.access_token, current_user.qbo_access_credential.access_secret)
    end
  
    def set_bill_payment_service
#      oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, session[:token], session[:secret])
      @bill_payment_service = Quickbooks::Service::BillPayment.new
      @bill_payment_service.access_token = @oauth_client
      @bill_payment_service.company_id = current_company_id
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
    
    def set_purchase_order_service
#      oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, session[:token], session[:secret])
      @purchase_order_service = Quickbooks::Service::PurchaseOrder.new
      @purchase_order_service.access_token = @oauth_client
      @purchase_order_service.company_id = current_company_id
    end
    
    def set_bill_service
#      oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, session[:token], session[:secret])
      @bill_service = Quickbooks::Service::Bill.new
      @bill_service.access_token = @oauth_client
      @bill_service.company_id = current_company_id
    end
    
    def set_account_service
#      oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, session[:token], session[:secret])
      @account_service = Quickbooks::Service::Account.new
      @account_service.access_token = @oauth_client
      @account_service.company_id = current_company_id
    end
    
    def set_company_service
#      oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, session[:token], session[:secret])
      @company_info_service = Quickbooks::Service::CompanyInfo.new
      @company_info_service.access_token = @oauth_client
      @company_info_service.company_id = current_company_id
      @company_info = @company_info_service.fetch_by_id(current_company_id)
    end
    
    # Use callbacks to share common setup or constraints between actions.
    def set_bill_payment
      #@bill_payment = BillPayment.find(params[:id])
      @bill_payment = @bill_payment_service.fetch_by_id(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def bill_payment_params
      # order matters here in that to have access to model attributes in uploader methods, they need to show up before the file param in this permitted_params list 
      params.require(:bill_payment).permit(:vendor, :doc_number, :pay_account, :total)
    end
    
#    def line_params
#      # order matters here in that to have access to model attributes in uploader methods, they need to show up before the file param in this permitted_params list 
##      params.require(:line).permit("item")
#      params.permit("item")
#    end
end
