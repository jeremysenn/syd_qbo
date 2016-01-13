class Vendor < ActiveRecord::Base
  
  #############################
  #     Instance Methods      #
  #############################
  
  #############################
  #     Class Methods         #
  #############################
  
  def self.customer(vendor_id)
    Customer.find(vendor_id)
  end
  
  def self.customer_photo_id_warning?(vendor_id, company_id)
    #customer = Customer.find_by_id(vendor_id)
    customer = Customer.where(vendorid: vendor_id, qb_company_id: company_id).last
    unless customer.blank?
      customer.photo_id_warning?
    else
      true
    end
  end
  
  def self.default_cust_pic_id(vendor_id, company_id)
    customer_photos = CustPic.where(cust_nbr: vendor_id, location: company_id, event_code: "Customer Photo")
    unless customer_photos.blank?
      return customer_photos.last.id
    else
      photo_ids = CustPic.where(cust_nbr: vendor_id, location: company_id, event_code: "Photo ID")
      unless photo_ids.blank?
        return photo_ids.last.id
      else
        return nil
      end
    end
  end
  
  def self.default_cust_pic(vendor_id, company_id)
    customer_photos = CustPic.where(cust_nbr: vendor_id, location: company_id, event_code: "Customer Photo")
    unless customer_photos.blank?
      return customer_photos.last
    else
      photo_ids = CustPic.where(cust_nbr: vendor_id, location: company_id, event_code: "Photo ID")
      unless photo_ids.blank?
        return photo_ids.last
      else
        return nil
      end
    end
  end
  
end

