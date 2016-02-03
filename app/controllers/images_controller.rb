class ImagesController < ApplicationController
  before_filter :authenticate_user!, :except => [:show_jpeg_image, :show_preview_image]
  before_action :set_image, only: [:show, :edit, :update, :show_jpeg_image, :show_preview_image, :destroy]
  before_action :set_oauth_client, only: [:advanced_search]
  before_action :set_vendor_service, only: [:advanced_search]
  before_action :set_item_service, only: [:advanced_search]
  
  load_and_authorize_resource :except => [:show_jpeg_image, :show_preview_image]

  respond_to :html, :js

  def index
    unless params[:q].blank? or params[:today] == true
      @ticket_number = params[:q][:ticket_nbr_eq]
      @start_date = params[:q][:sys_date_time_gteq]
      @end_date = params[:q][:sys_date_time_lteq]
      
      if (@start_date.present? and @end_date.present?) and (@start_date == @end_date) # User select the same date for both
        params[:q][:sys_date_time_lteq] = params[:q][:sys_date_time_lteq].to_date.tomorrow.strftime("%Y-%m-%d") 
      end
      
      search = Image.ransack(params[:q])
#      search.sorts = "#{sort} #{direction}"
      
      ### Only show one image per ticket by default, unless there is a ticket number being searched ###
      unless @ticket_number.blank?
        params[:one_image_per_ticket] == '0'
        @one_image_per_ticket = '0'
        search.sorts = "sys_date_time desc"
        @images = search.result.page(params[:page]).per(6)
      else
        search.sorts = "ticket_nbr desc"
        if params[:one_image_per_ticket] == '1' or not params[:one_image_per_ticket] == '0'
          @images = search.result
          @images = Kaminari.paginate_array(@images.to_a.uniq { |image| image.ticket_nbr }).page(params[:page]).per(6)
        else
          @images = search.result.page(params[:page]).per(6)
        end
      end
      
    else # Show today's tickets
      # Default search to today's images
      @today = true
#      search = Image.ransack(:sys_date_time_gteq => Date.today, :sys_date_time_lteq => Date.today.tomorrow)
      search = Image.ransack(:sys_date_time_gteq => Date.today.beginning_of_day, :sys_date_time_lteq => Date.today.end_of_day, :location_eq => current_user.location)
      params[:q] = {}
      @start_date = Date.today.to_s
#      @end_date = Date.today.tomorrow.to_s
      @end_date = Date.today.to_s
#      search.sorts = "sys_date_time desc"
      search.sorts = "ticket_nbr desc"
      @images = search.result
      @images = Kaminari.paginate_array(@images.to_a.uniq { |image| image.ticket_nbr }).page(params[:page]).per(6)
#      @images = search.result.page(params[:page]).per(8).to_a.uniq { |image| image.ticket_nbr }.reverse # Get only one of each ticket number
    end
  end

  def show
    @ticket_number = @image.ticket_nbr
    respond_with(@image)
  end

  def new
    @image = Image.new
  end

  def edit
  end

  def create
    @image = Image.new(image_params)
    @image.save
    respond_with(@image)
  end

  def update
    @image.update(image_params)
    respond_with(@image)
  end
  
  def show_jpeg_image
    send_data @image.jpeg_image, :type => 'image/jpeg',:disposition => 'inline'
  end
  
  def show_preview_image
    send_data @image.preview, :type => 'image/jpeg',:disposition => 'inline'
  end
  
  def send_pdf_data
    send_data @image.jpeg_image, :type => 'application/pdf',:disposition => 'attachment'
  end
  
  def destroy
    @image.destroy
    respond_with(@image)
  end
  
  def advanced_search
    @vendors = @vendor_service.query(nil, :per_page => 1000)
    @items = @item_service.query(nil, :per_page => 1000)
    unless params[:q].blank?
      @ticket_number = params[:q][:ticket_nbr_eq]
      @start_date = params[:q][:sys_date_time_gteq]
      @end_date = params[:q][:sys_date_time_lteq]
      @customer_number = params[:q][:cust_nbr_eq]
      @commodity_name = params[:q][:cmdy_name_cont]

      if (@start_date.present? and @end_date.present?) and (@start_date == @end_date) # User select the same date for both
        params[:q][:sys_date_time_lteq] = params[:q][:sys_date_time_lteq].to_date.tomorrow.strftime("%Y-%m-%d") 
      end

      search = Image.ransack(params[:q])

      ### Only show one image per ticket by default, unless there is a ticket number being searched ###
      unless @ticket_number.blank?
        params[:one_image_per_ticket] == '0'
        @one_image_per_ticket = '0'
        search.sorts = "sys_date_time desc"
        @images = search.result.page(params[:page]).per(6)
      else
        search.sorts = "ticket_nbr desc"
        if params[:one_image_per_ticket] == '1' or not params[:one_image_per_ticket] == '0'
          @images = search.result
          @images = Kaminari.paginate_array(@images.to_a.uniq { |image| image.ticket_nbr }).page(params[:page]).per(6)
        else
          @images = search.result.page(params[:page]).per(6)
        end
      end
    else # Show today's tickets
      # Default search to today's images
      @today = true
      search = Image.ransack(:sys_date_time_gteq => Date.today.beginning_of_day, :sys_date_time_lteq => Date.today.end_of_day, :location_eq => current_user.location)
      params[:q] = {}
      @start_date = Date.today.to_s
      @end_date = Date.today.to_s
      search.sorts = "ticket_nbr desc"
      @images = search.result
      @images = Kaminari.paginate_array(@images.to_a.uniq { |image| image.ticket_nbr }).page(params[:page]).per(6)
    end
  end

  private
    def set_image
      @image = Image.find(params[:id])
    end

    def image_params
      params.require(:image).permit(:ticket_nbr)
    end
    
    def set_oauth_client
      @oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, current_user.qbo_access_credential.access_token, current_user.qbo_access_credential.access_secret)
    end
  
    def set_vendor_service
      @vendor_service = Quickbooks::Service::Vendor.new
      @vendor_service.access_token = @oauth_client
      @vendor_service.company_id = current_company_id
    end
    
    def set_item_service
      @item_service = Quickbooks::Service::Item.new
      @item_service.access_token = @oauth_client
      @item_service.company_id = current_company_id
    end
    
end
