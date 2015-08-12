class WelcomeController < ApplicationController
  def index
    if user_signed_in? && session[:token]
      oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, session[:token], session[:secret])
      @company_info_service = Quickbooks::Service::CompanyInfo.new
      @company_info_service.access_token = oauth_client
      @company_info_service.company_id = session[:realm_id]
      @company_info = @company_info_service.fetch_by_id(session[:realm_id])
    end
  end
end
