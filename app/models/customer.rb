class Customer < ActiveRecord::Base
  
  establish_connection :jpegger
  
  self.table_name = 'customer'
  
  
  #############################
  #     Instance Methods      #
  ############################
  
  def photo_id_warning?
    search_results = CustPic.where(location: qb_company_id, cust_nbr: vendorid, event_code: "Photo ID")
    unless search_results.blank? 
      # At least one Photo ID picture found
      if expiration_date.blank? or expiration_date < Date.today
        return true # ID has no expiration set or is expired
      else
        return false # ID is NOT expired
      end
    else
      return true # No Photo ID picture found
    end
  end
  
  def weight_in_kilograms
    unless weight.blank?
      (0.453592 * weight.to_i).to_i
    end
  end
  
  def height_in_meters
    unless height.blank?
      (0.0254 * height.to_i).round(2)
    end
  end
  
  def full_name
    "#{first_name} #{last_name}"
  end
  
  #############################
  #     Class Methods      #
  #############################
  
  
end

