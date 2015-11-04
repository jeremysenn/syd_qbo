class DeviceGroup < ActiveRecord::Base
  
  establish_connection :tud_config
  
  self.primary_key = 'DeviceGroupID'
  self.table_name = 'DeviceGroups'
  
#  belongs_to :company, foreign_key: "CompanyID"
#  belongs_to :workstation, foreign_key: "WorkstationID"
  
  #############################
  #     Instance Methods      #
  ############################
  
  
  #############################
  #     Class Methods      #
  #############################
  
  
end

