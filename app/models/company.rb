class Company < ActiveRecord::Base
  
  establish_connection :tud_config
  
  self.primary_key = 'CompanyID'
  self.table_name = 'Company'
  
  has_many :users
  has_many :workstations
  has_many :devices
  has_one :qbo_access_credential
  
  #############################
  #     Instance Methods      #
  ############################
  
  def users
    User.where(location: self.CompanyID)
  end
  
  def workstations
    Workstation.where("CompanyID" => self.CompanyID)
  end
  
  def devices
    Device.where("CompanyID" => self.CompanyID)
  end
  
  #############################
  #     Class Methods      #
  #############################
  
  
end