class Company < ActiveRecord::Base
  
  establish_connection :tud_config
  
  self.primary_key = 'CompanyID'
  self.table_name = 'Company'
  
  has_many :users
  has_many :workstations
  has_many :devices
  has_one :qbo_access_credential
  has_one :jpegger_contract, foreign_key: "contract_id"
  
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
  
  def scale_devices
    Device.where(CompanyID: self.CompanyID, DeviceType: 21)
  end
  
  def device_groups
    DeviceGroup.where("CompanyID" => self.CompanyID.to_i)
  end
  
  #############################
  #     Class Methods      #
  #############################
  
  
end