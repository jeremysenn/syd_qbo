class DeviceGroupMember < ActiveRecord::Base
  
  establish_connection :tud_config
  
#  self.primary_key = 'DeviceGroupMemberID'
  self.table_name = 'DeviceGroupMembers'
  
#  belongs_to :company, foreign_key: "CompanyID"
#  belongs_to :workstation, foreign_key: "WorkstationID"
  
  #############################
  #     Instance Methods      #
  ############################
  
  
  #############################
  #     Class Methods      #
  #############################
  
  
end

