class JpeggerContractsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  # GET /jpegger_contracts
  # GET /jpegger_contracts.json
  def index
    @jpegger_contracts = current_user.jpegger_contracts
  end

  # GET /jpegger_contracts/1
  # GET /jpegger_contracts/1.json
  def show
  end

  # GET /jpegger_contracts/new
  def new
  end

  # GET /jpegger_contracts/1/edit
  def edit
  end

  # POST /jpegger_contracts
  # POST /jpegger_contracts.json
  def create
    @jpegger_contract = JpeggerContract.new(jpegger_contract_params)

    respond_to do |format|
      if @jpegger_contract.save
        format.html { redirect_to @jpegger_contract, notice: 'JpeggerContract was successfully created.' }
        format.json { render :show, status: :created, location: @jpegger_contract }
      else
        format.html { render :new }
        format.json { render json: @jpegger_contract.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /jpegger_contracts/1
  # PATCH/PUT /jpegger_contracts/1.json
  def update
    respond_to do |format|
      if @jpegger_contract.update(jpegger_contract_params)
#        format.html { redirect_to @jpegger_contract, notice: 'JpeggerContract was successfully updated.' }
        format.html { redirect_to current_company, notice: 'JpeggerContract was successfully updated.' }
        format.json { render :show, status: :ok, location: @jpegger_contract }
      else
        format.html { render :edit }
        format.json { render json: @jpegger_contract.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /jpegger_contracts/1
  # DELETE /jpegger_contracts/1.json
  def destroy
    @jpegger_contract.destroy
    respond_to do |format|
      format.html { redirect_to jpegger_contracts_url, notice: 'JpeggerContract was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_jpegger_contract
      @jpegger_contract = JpeggerContract.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def jpegger_contract_params
      params.require(:jpegger_contract).permit(:contract_id, :contract_name, :text1, :text2, :text3, :text4)
    end
end
