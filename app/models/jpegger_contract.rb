class JpeggerContract < ActiveRecord::Base

  establish_connection :jpegger

  self.table_name = 'contracts'
  self.primary_key = 'contract_id'
  
  #############################
  #     Instance Methods      #
  ############################
  
  def company
    Company.find_by_CompanyID(contract_id)
  end
  
  def verbage
    "#{text1} #{text2} #{text3} #{text4}"
  end
  
  #############################
  #     Class Methods      #
  #############################

end

