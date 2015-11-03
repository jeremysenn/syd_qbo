class QboAccessCredential < ActiveRecord::Base
  
  after_initialize :add_expiration_and_reconnect_dates, :if => :new_record?
  
#  belongs_to :user
  belongs_to :company
  
  #############################
  #     Instance Methods      #
  ############################
  
  def add_expiration_and_reconnect_dates
    self.token_expires_at = 6.months.from_now
    self.reconnect_token_at = 5.months.from_now
  end
  
  def ready_to_expire?
    reconnect_token_at < Date.today
  end
  
  #############################
  #     Class Methods      #
  #############################
  
  def self.remove_expired_token_credentials
    QboAccessCredential.select{|q| (q.ready_to_expire?)}.each do |qbo_access_credential|
      qbo_access_credential.destroy
    end
  end
  
end

