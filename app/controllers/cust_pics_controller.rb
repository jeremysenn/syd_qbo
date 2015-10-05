class CustPicsController < ApplicationController
  before_filter :authenticate_user!, :except => [:show_jpeg_image, :show_preview_image]
  before_action :set_cust_pic, only: [:show, :edit, :update, :show_jpeg_image, :show_preview_image, :destroy]
  
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
      
      search = CustPic.ransack(params[:q])
#      search.sorts = "#{sort} #{direction}"
      
      ### Only show one cust_pic per ticket by default, unless there is a ticket number being searched ###
      unless @ticket_number.blank?
        params[:one_cust_pic_per_ticket] == '0'
        @one_cust_pic_per_ticket = '0'
        search.sorts = "sys_date_time desc"
        @cust_pics = search.result.page(params[:page]).per(6)
      else
        search.sorts = "ticket_nbr desc"
        if params[:one_cust_pic_per_ticket] == '1' or not params[:one_cust_pic_per_ticket] == '0'
          @cust_pics = search.result
          @cust_pics = Kaminari.paginate_array(@cust_pics.to_a.uniq { |cust_pic| cust_pic.ticket_nbr }).page(params[:page]).per(6)
        else
          @cust_pics = search.result.page(params[:page]).per(6)
        end
      end
      
    else # Show today's tickets
      # Default search to today's cust_pics
      @today = true
#      search = CustPic.ransack(:sys_date_time_gteq => Date.today, :sys_date_time_lteq => Date.today.tomorrow)
      search = CustPic.ransack(:sys_date_time_gteq => Date.today.beginning_of_day, :sys_date_time_lteq => Date.today.end_of_day)
      params[:q] = {}
      @start_date = Date.today.to_s
#      @end_date = Date.today.tomorrow.to_s
      @end_date = Date.today.to_s
#      search.sorts = "sys_date_time desc"
      search.sorts = "ticket_nbr desc"
      @cust_pics = search.result
      @cust_pics = Kaminari.paginate_array(@cust_pics.to_a.uniq { |cust_pic| cust_pic.ticket_nbr }).page(params[:page]).per(6)
#      @cust_pics = search.result.page(params[:page]).per(8).to_a.uniq { |cust_pic| cust_pic.ticket_nbr }.reverse # Get only one of each ticket number
    end
  end

  def show
    respond_with(@cust_pic)
  end

  def new
    @cust_pic = CustPic.new
  end

  def edit
  end

  def create
    @cust_pic = CustPic.new(cust_pic_params)
    @cust_pic.save
    respond_with(@cust_pic)
  end

  def update
    @cust_pic.update(cust_pic_params)
    respond_with(@cust_pic)
  end
  
  def show_jpeg_image
    send_data @cust_pic.jpeg_image, :type => 'image/jpeg',:disposition => 'inline'
  end
  
  def show_preview_image
    send_data @cust_pic.preview, :type => 'image/jpeg',:disposition => 'inline'
  end
  
  def destroy
    @cust_pic.destroy
    respond_with(@cust_pic)
  end

  private
    def set_cust_pic
      @cust_pic = CustPic.find(params[:id])
    end

    def cust_pic_params
#      params.require(:cust_pic).permit(:ticket_nbr)
    end
    
end
