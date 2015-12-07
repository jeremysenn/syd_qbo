class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  def mobile_device?
    request.user_agent =~ /Mobile|webOS/
  end
  helper_method :mobile_device?
  
  def after_sign_in_path_for(resource)
    root_path
  end
  
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end
  
  private
  def current_company_id
    session[:realm_id] ||= current_user.location
  end
  helper_method :current_company_id
  
  def current_company
    current_user.company
  end
  helper_method :current_company
  
end
