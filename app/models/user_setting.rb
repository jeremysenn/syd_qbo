class UserSetting < ActiveRecord::Base
  
  belongs_to :user
  
  
  #############################
  #     Instance Methods      #
  ############################
  
  def images?
    table_name == "images"
  end
  
  def shipments
    table_name == "shipments"
  end
  
  #############################
  #     Class Methods      #
  #############################
end
