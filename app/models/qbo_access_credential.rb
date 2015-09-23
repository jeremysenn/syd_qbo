class QboAccessCredential < ActiveRecord::Base
  
  after_initialize :add_expiration_and_reconnect_dates, :if => :new_record?
  
  belongs_to :user
  
  #############################
  #     Instance Methods      #
  ############################
  
  def add_expiration_and_reconnect_dates
    self.token_expires_at = 6.months.from_now
    self.reconnect_token_at = 5.months.from_now
  end
  
  #############################
  #     Class Methods      #
  #############################
  
end

