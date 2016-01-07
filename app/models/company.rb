class Company < ActiveRecord::Base
  
  establish_connection :tud_config
  
  self.primary_key = 'CompanyID'
  self.table_name = 'Company'
  
  has_many :users
  has_many :workstations
  has_many :devices
  has_one :qbo_access_credential
#  has_one :jpegger_contract, foreign_key: "contract_id"
  
  #############################
  #     Instance Methods      #
  ############################
  
  def users
    User.where(location: self.CompanyID.to_i)
  end
  
  def workstations
    Workstation.where("CompanyID" => self.CompanyID.to_i)
  end
  
  def devices
    Device.where("CompanyID" => self.CompanyID.to_i)
  end
  
  def scale_devices
    Device.where(CompanyID: self.CompanyID, DeviceType: 21)
  end
  
  def device_groups
    DeviceGroup.where("CompanyID" => self.CompanyID.to_i)
  end
  
  def jpegger_contract
    JpeggerContract.where(contract_id: self.CompanyID.to_i).last
  end
  
  def leads_online_config_settings_present?
    if leads_online_store_id.blank? or leads_online_ftp_username.blank? or leads_online_ftp_password.blank?
      return false
    else
      return true
    end
  end
  
  #############################
  #     Class Methods      #
  #############################
  
  
end