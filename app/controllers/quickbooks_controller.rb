class QuickbooksController < ApplicationController

  def authenticate
    callback = oauth_callback_quickbooks_url
    token = $qb_oauth_consumer.get_request_token(:oauth_callback => callback)
    session[:qb_request_token] = Marshal.dump(token)
    redirect_to("https://appcenter.intuit.com/Connect/Begin?oauth_token=#{token.token}") and return
  end

  def oauth_callback
    quickbooks_authentication = Marshal.load(session[:qb_request_token]).get_access_token(:oauth_verifier => params[:oauth_verifier])
    session[:token] = quickbooks_authentication.token
    session[:secret] = quickbooks_authentication.secret
    session[:realm_id] = params['realmId']
    redirect_to root_url, notice: "Your QuickBooks account has been successfully linked."
  end
  
end
