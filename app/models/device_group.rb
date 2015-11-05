class DeviceGroup < ActiveRecord::Base
  
  establish_connection :tud_config
  
  self.primary_key = 'DeviceGroupID'
  self.table_name = 'DeviceGroups'
  
  belongs_to :company, foreign_key: "CompanyID"
#  has_many :device_group_members
  has_many :user_settings
  
  #############################
  #     Instance Methods      #
  ############################
  
  def device_group_members
    DeviceGroupMember.where(DeviceGroupID: id)
  end
  
  def devices
    device_group_members.map{|dgm| dgm.device }
  end
  
  #############################
  #     Class Methods      #
  #############################
  
  
end

