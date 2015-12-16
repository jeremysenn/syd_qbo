class JpeggerContract < ActiveRecord::Base

  establish_connection :jpegger

  self.table_name = 'contracts'
  self.primary_key = 'contract_id'
  
#  belongs_to :company
  
  #############################
  #     Instance Methods      #
  ############################
  
  def company
    Company.find_by_CompanyID(contract_id)
  end
  
  def verbiage
    "<p>#{text1}</p><p>#{text2}</p><p>#{text3}</p><p>#{text4}</p>"
  end
  
  #############################
  #     Class Methods      #
  #############################

end

