class WelcomeController < ApplicationController
  def index
    #if user_signed_in? && session[:token]
    if user_signed_in? and current_user.qbo_access_credential.present?
#      @oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, current_user.qbo_access_credential.access_token, current_user.qbo_access_credential.access_secret)
#      @company_info_service = Quickbooks::Service::CompanyInfo.new
#      @company_info_service.access_token = @oauth_client
#      @company_info_service.company_id = current_company_id
#      @company_info = @company_info_service.fetch_by_id(current_company_id)
#      
#      oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, session[:token], session[:secret])
#      @company_info_service = Quickbooks::Service::CompanyInfo.new
#      @company_info_service.access_token = oauth_client
#      @company_info_service.company_id = session[:realm_id]
#      @company_info = @company_info_service.fetch_by_id(session[:realm_id])
    end
  end
  
  def privacy
  end
  
  def tos
  end
end
