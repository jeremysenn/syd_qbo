class CompaniesController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_company, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource

  # GET /companies
  # GET /companies.json
  def index
#    @companies = Company.all
  end

  # GET /companies/1
  # GET /companies/1.json
  def show
  end

  # GET /companies/new
  def new
    @company = Company.new
  end

  # GET /companies/1/edit
  def edit
  end

  # POST /companies
  # POST /companies.json
  def create
    respond_to do |format|
      format.html { 
        @company = Company.new(company_params)
        if @company.save
          redirect_to :back, notice: 'CustPic file was successfully created.' 
        else
          render :new
        end
        }
      format.json { 
        @company = Company.new(company_params)
        if @company.save
          render :show, status: :created, location: @company 
        else
          render json: @company.errors, status: :unprocessable_entity
        end
        }
      format.js {
#        @company = Company.create(user_id: 1, customer_number: "77", location: "404168351", event_code: "Photo ID", remote_file_url: "http://qb.scrapyarddog.com/tud_devices/show_scanned_jpeg_image")
        @company = Company.create(company_params)
      }
    end
  end

  # PATCH/PUT /companies/1
  # PATCH/PUT /companies/1.json
  def update
    respond_to do |format|
      if @company.update(company_params)
        format.html { redirect_to @company, notice: 'CustPic file was successfully updated.' }
        format.json { render :show, status: :ok, location: @company }
      else
        format.html { render :edit }
        format.json { render json: @company.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /companies/1
  # DELETE /companies/1.json
  def destroy
    @company.destroy
    respond_to do |format|
      format.html { redirect_to companies_url, notice: 'CustPic file was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_company
      @company = Company.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def company_params
      # order matters here in that to have access to model attributes in uploader methods, they need to show up before the file param in this permitted_params list 
      params.require(:company).permit(:custom_field_1, :custom_field_1_value, :custom_field_2, :custom_field_2_value, :logo_url, :leads_online_store_id, :leads_online_ftp_username, :leads_online_ftp_password)
    end
end
