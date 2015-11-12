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
    device_group_members.sort_by{|dgm| dgm.DevOrder}.map{|dgm| dgm.device }
  end
  
  def scale_devices
    devices.select {|device| device.DeviceType == 22}
  end
  
  def camera_devices
    devices.select {|device| device.DeviceType == 5}
  end
  
  def license_reader_devices
    devices.select {|device| device.DeviceType == 6 or device.DeviceType == 7}
  end
  
  def license_imager_devices
    devices.select {|device| device.DeviceType == 6 or device.DeviceType == 18}
  end
  
  def finger_print_reader_devices
    devices.select {|device| device.DeviceType == 13 or device.DeviceType == 24}
  end
  
  def signature_pad_devices
    devices.select {|device| device.DeviceType == 12 or device.DeviceType == 17 or device.DeviceType == 23}
  end
  
  def printer_devices
    devices.select {|device| device.DeviceType == 21}
  end
  
  #############################
  #     Class Methods      #
  #############################
  
  
end

