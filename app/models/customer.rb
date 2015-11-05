class Customer < ActiveRecord::Base
  
  establish_connection :jpegger
  
  self.table_name = 'customer'
  
  
  #############################
  #     Instance Methods      #
  ############################
  
  
  #############################
  #     Class Methods      #
  #############################
  
  
end

