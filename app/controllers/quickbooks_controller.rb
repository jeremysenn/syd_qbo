class QuickbooksController < ApplicationController
  
  def authenticate
    callback = oauth_callback_quickbooks_url
    token = $qb_oauth_consumer.get_request_token(:oauth_callback => callback)
    session[:qb_request_token] = Marshal.dump(token)
    redirect_to("https://appcenter.intuit.com/Connect/Begin?oauth_token=#{token.token}") and return
  end

  def oauth_callback
    quickbooks_authentication = Marshal.load(session[:qb_request_token]).get_access_token(:oauth_verifier => params[:oauth_verifier])
#    session[:token] = quickbooks_authentication.token
#    session[:secret] = quickbooks_authentication.secret
#    session[:realm_id] = params['realmId']
    QboAccessCredential.create(user_id: current_user.id, access_token: quickbooks_authentication.token, 
      access_secret: quickbooks_authentication.secret, company_id: params['realmId'])
    
    # If current_user doesn't have a location (company_id), then set it with params['realmId'] (the QB company ID)
    if current_user.location.blank?
      current_user.update_attribute(:location, params['realmId'])
    end
    
    
    ### Set Rails.cache for Quickbooks Vendors and Items ###
    oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, session[:token], session[:secret])
    @vendor_service = Quickbooks::Service::Vendor.new
    @vendor_service.access_token = oauth_client
    @vendor_service.company_id = session[:realm_id]
    
    vendors = @vendor_service.query(nil, :per_page => 1000)
    Rails.cache.delete("all_vendors")
    Rails.cache.fetch("all_vendors") {Hash[vendors.map{ |v| [v.display_name,v.id] }]}
    
    @item_service = Quickbooks::Service::Item.new
    @item_service.access_token = oauth_client
    @item_service.company_id = session[:realm_id]
    
    items = @item_service.query(nil, :per_page => 1000)
    Rails.cache.delete("all_items")
    Rails.cache.fetch("all_items") {Hash[items.map{ |i| ["#{i.name} (#{i.description})",i.id] }]}
    
    redirect_to root_url, notice: "Your QuickBooks account has been successfully linked."
  end
  
end
