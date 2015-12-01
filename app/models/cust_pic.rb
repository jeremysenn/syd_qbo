class CustPic < ActiveRecord::Base
  #  new columns need to be added here to be writable through mass assignment
#  attr_accessible :capture_seq_nbr, :blob_id, :camera_name, :camera_group, :sys_date_time, :location,
#    :branch_code, :cust_nbr, :event_code, :ticket_nbr, :contr_nbr, :booking_nbr, :container_nbr, :cust_name, :thumbnail

  establish_connection :jpegger

  self.primary_key = 'capture_seq_nbr'
  self.table_name = 'CUST_PICS_data'
  
  belongs_to :blob

  ### SEARCH WITH RANSACK ###
  def self.ransack_search(query, sort, direction)
    search = CustPic.ransack(query)
    search.sorts = "#{sort} #{direction}"
    cust_pics = search.result

    return cust_pics
  end

  def jpeg_image
    blob.jpeg_image
  end

  def preview
    blob.preview
  end
  
  def jpeg_image_data_uri
    "data:image/jpg;base64, #{Base64.encode64(jpeg_image)}"
  end
  
  def preview_data_uri
    unless preview.blank?
      "data:image/jpg;base64, #{Base64.encode64(preview)}"
    else
      nil
    end
  end

end