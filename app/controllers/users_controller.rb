class UsersController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  
  def index
  end
  
  # GET /users/1/edit
  def edit
  end
  
  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      admin_user = User.find_by_email(user_params[:admin_email])
      @qbo_access_credential = QboAccessCredential.find_by_user_id(admin_user.id) unless admin_user.blank?
      if admin_user.present? and @qbo_access_credential.present?
        @user.update_attribute(:location, admin_user.location)
        format.html { redirect_to root_path, notice: "#{@user.email} was successfully added to Quickbooks Online company." }
      else
        format.html { 
          flash[:notice] = "Company is not yet connected to SYD"
          @connecting_to_quickbooks = true
          render :edit
          }
      end
#      if @user.update(user_params)
#        format.html { redirect_to root_path, notice: 'User was successfully updated.' }
#        format.json { render :show, status: :ok, location: @user }
#      else
#        format.html { render :edit }
#        format.json { render json: @user.errors, status: :unprocessable_entity }
#      end
    end
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:admin_email)
    end
  
  
end
