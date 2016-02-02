class Company < ActiveRecord::Base
  
  establish_connection :tud_config
  
  self.primary_key = 'CompanyID'
  self.table_name = 'Company'
  
  mount_uploader :logo_url, LogoUploader
  
  has_many :users
  has_many :workstations
  has_many :devices
  has_one :qbo_access_credential
#  has_one :jpegger_contract, foreign_key: "contract_id"
  
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
    DeviceGroup.where("CompanyID" => self.CompanyID)
  end
  
  def jpegger_contract
    JpeggerContract.where(contract_id: self.CompanyID).last
  end
  
  def leads_online_config_settings_present?
    if leads_online_store_id.blank? or leads_online_ftp_username.blank? or leads_online_ftp_password.blank?
      return false
    else
      return true
    end
  end
  
  def bwi_config_settings_present?
    if bwi_company_id.blank? or bwi_company_name.blank? or bwi_username.blank? or bwi_password.blank? or bwi_upload_url.blank?
      return false
    else
      return true
    end
  end
  
  #############################
  #     Class Methods      #
  #############################
  
  
end

