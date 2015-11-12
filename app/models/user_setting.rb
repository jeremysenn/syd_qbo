class UserSetting < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :device_group
  
  
  #############################
  #     Instance Methods      #
  ############################
  
  def images?
    table_name == "images"
  end
  
  def shipments
    table_name == "shipments"
  end
  
  def devices
    device_group.devices
  end
  
  def scale_devices
    device_group.scale_devices
  end
  
  def camera_devices
    device_group.camera_devices
  end
  
  def license_reader_devices
    device_group.license_reader_devices
  end
  
  def license_imager_devices
    device_group.license_imager_devices
  end
  
  def printer_devices
    device_group.printer_devices
  end
  
  #############################
  #     Class Methods      #
  #############################
end
