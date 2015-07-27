class LookupDefsController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_lookup_def, only: [:show, :edit, :update, :destroy]
#  load_and_authorize_resource

  # GET /lookup_defs
  # GET /lookup_defs.json
  def index
    @lookup_defs = LookupDef.where("FieldName" => "event_code")
  end

  # GET /lookup_defs/1
  # GET /lookup_defs/1.json
  def show
  end

  # GET /lookup_defs/new
  def new
    @lookup_def = LookupDef.new
  end

  # GET /lookup_defs/1/edit
  def edit
  end

  # POST /lookup_defs
  # POST /lookup_defs.json
  def create
    @lookup_def = LookupDef.new(lookup_def_params)

    respond_to do |format|
      if @lookup_def.save
#        format.html { redirect_to images_path, notice: 'Lookup def was successfully created.' }
        format.html { redirect_to @lookup_def, notice: 'Lookup def was successfully created.' }
        format.json { render :show, status: :created, location: @lookup_def }
      else
        format.html { render :new }
        format.json { render json: @lookup_def.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /lookup_defs/1
  # PATCH/PUT /lookup_defs/1.json
  def update
    respond_to do |format|
      if @lookup_def.update(lookup_def_params)
        format.html { redirect_to @lookup_def, notice: 'Lookup def was successfully updated.' }
        format.json { render :show, status: :ok, location: @lookup_def }
      else
        format.html { render :edit }
        format.json { render json: @lookup_def.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /lookup_defs/1
  # DELETE /lookup_defs/1.json
  def destroy
    @lookup_def.destroy
    respond_to do |format|
      format.html { redirect_to lookup_defs_url, notice: 'Lookup def was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_lookup_def
      @lookup_def = LookupDef.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def lookup_def_params
      params.require(:lookup_def).permit(:tableName, :FieldName, :LookupValue, :LookupDisplay)
    end
end
