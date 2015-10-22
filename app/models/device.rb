class Device < ActiveRecord::Base
  
  establish_connection :tud_config
  
#  self.primary_key = 'capture_seq_nbr'
  self.table_name = 'Device'
  
  #############################
  #     Instance Methods      #
  ############################
  
  #############################
  #     Class Methods      #
  #############################
  
  
end

