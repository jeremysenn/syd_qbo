class Image < ActiveRecord::Base
#  attr_accessible :capture_seq_nbr, :ticket_nbr, :receipt_nbr, :blob_id, :camera_name, :camera_group, :sys_date_time,
#    :location, :branch_code, :event_code, :cust_nbr, :thumbnail, :cmdy_name, :cmdy_nbr

  establish_connection :jpegger

  self.primary_key = 'capture_seq_nbr'
  self.table_name = 'images_data'

  belongs_to :blob
  
  #############################
  #     Instance Methods      #
  ############################

  def jpeg_image
    blob.jpeg_image
  end

  def preview
    blob.preview
  end
  
  def jpeg_image_data_uri
    unless jpeg_image.blank?
      "data:image/jpg;base64, #{Base64.encode64(jpeg_image)}"
    else
      nil
    end
  end
  
  def jpeg_image_base_64
    unless jpeg_image.blank?
      Base64.encode64(jpeg_image)
    else
      nil
    end
  end
  
  def preview_data_uri
    unless preview.blank?
      "data:image/jpg;base64, #{Base64.encode64(preview)}"
    else
      nil
    end
  end
  
  def preview_base_64
    unless preview.blank?
      Base64.encode64(preview)
    else
      nil
    end
  end
  
  def is_customer_image(customer_name)
    Image.where(ticket_nbr: ticket_nbr, cust_name: customer_name).exists?
  end
  
  def signature?
    event_code == "Signature"
  end
  
  def pdf?
     blob.jpeg_image[0..3] == "%PDF"
  end
  
  #############################
  #     Class Methods      #
  #############################
  
  ### SEARCH WITH RANSACK ###
  def self.ransack_search(query, sort, direction)
    search = Image.ransack(query)
    search.sorts = "#{sort} #{direction}"
    images = search.result
    images = images + RtLookup.receipt_lookup(query[:ticket_nbr_eq]) # Check for ticket in RtLookup table as well

    return images
  end

  ### SEARCH WITH RANSACK BY EXTERNAL/LAW USER ###
  def self.ransack_search_external_user(query, sort, direction, customer_name)
    search = Image.ransack(query)
    search.sorts = "#{sort} #{direction}"
    images = []
    search.result.each do |image|
      if image.is_customer_image(customer_name)
        images << image
      end
    end

    return images
  end
  
  ### SEARCH ARCHIVES WITH RANSACK ###
  def self.mounted_archives_ransack_search(query, sort, direction)
    # Search through the mounted archives if any exists
    images = []
    if (MountedArchive.count > 0)
      MountedArchive.all.each do |mounted_archive|
        image_class = create_image_archive_subclass(mounted_archive)
        search = image_class.ransack(query)
#        search = "ImageArchive#{index+1}".constantize.ransack(query)
        images = images + search.result
        unless images.blank? #
          break #break out of do loop because we don't have to keep going once we get some results from an archive database
        end
      end
    end
    return images
  end
  
  ### FIND ARCHIVE RECORD WITH BY CAPTURES_SEQ_NBR ###
  def self.mounted_archives_find(id)
    # Search through the mounted archives if any exists
    if (MountedArchive.count > 0)
      MountedArchive.all.each do |mounted_archive|
        image_class = create_image_archive_subclass(mounted_archive)
        image = image_class.find(id)
        unless image.blank?
          return image
          break
        end
      end
    else
      return nil
    end
  end

  ### SEARCH BY TICKET NUMBER AND EVENT CODE ###
  def self.ticket_and_event_search(ticket_number, branch_code, event_code)
    unless branch_code.blank?
#      images = Image.find_all_by_ticket_nbr_and_branch_code_and_event_code(ticket_number, branch_code, event_code, :order => :sys_date_time)#.last(20)
      images = Image.where(ticket_nbr: ticket_number, branch_code: branch_code, event_code: event_code).order(:sys_date_time)
    else
#      images = Image.find_all_by_ticket_nbr_and_event_code(ticket_number,  event_code, :order => :sys_date_time)#.last(20)
      images = Image.where(ticket_nbr: ticket_number, event_code: event_code).order(:sys_date_time)
    end

    return images
  end

  ### SEARCH ARCHIVES BY TICKET NUMBER ###
  def self.ticket_search_mounted_archives(ticket_number, branch_code)
    images = []
    MountedArchive.all.each do |mounted_archive|
      if mounted_archive.client_active? # Check to see if able to successfully connect to mounted archive database
        connect_database(mounted_archive)
        unless branch_code.blank?
          images << Image.find_all_by_ticket_nbr_and_branch_code(ticket_number, branch_code, :order => :sys_date_time).flatten
        else
          images << Image.find_all_by_ticket_nbr(ticket_number, :order => :sys_date_time).flatten
        end
      end
    end
    establish_connection :development
    return images
  end


  ### SEARCH BY DATE ###
  def self.date_search(date, branch_code)
    unless branch_code.blank?
      search = Image.ransack(:sys_date_time_gt => date.beginning_of_day, :sys_date_time_lt => date.end_of_day, :branch_code_eq => branch_code)
    else
      search = Image.ransack(:sys_date_time_gt => date.beginning_of_day, :sys_date_time_lt => date.end_of_day)
    end
    images = search.result
    
    return images
  end
  
  def self.todays_tickets
    search = Image.ransack(:sys_date_time_gteq => Date.today.beginning_of_day, :sys_date_time_lteq => Date.today.end_of_day)
    images = search.result
    return images
  end
  
  def self.event_codes
    Image.select(:event_code).distinct.reject{ |i| i.event_code.blank?}
  end

#  def check_or_define_thumbnail
#    if thumbnail.blank?
#      unless Image.where(ticket_nbr: ticket_nbr, location: location, thumbnail: true).exists?
#        thumbnail_image = Image.where(ticket_nbr: ticket_nbr, location: location).first
#        thumbnail_image.update_attribute(:thumbnail, true)
#      end
#    end
#  end

end

def create_image_archive_subclass(mounted_archive)
  Class.new(super_class = Image) do
    def self.name
      "DynamicMountedArchiveImageModel"
    end
    
    if mounted_archive.DBType == 0
      adapter = 'sqlserver'
    elsif mounted_archive.DBType == "MySQL"
      adapter = 'mysql2'
    end
    establish_connection(
    :adapter  => "#{adapter}",
    :host     => mounted_archive.Server,
    :username => mounted_archive.Login,
    :password => mounted_archive.Password,
  #    :password => mounted_archive.decrypted_password,
    :database => mounted_archive.Archive
    )
  end
end

#class ImageArchive1 < Image
#  if MountedArchive.all.count >= 1
#    first_mounted_archive = MountedArchive.first
#    if first_mounted_archive.database_type == "SQL"
#      adapter = 'sqlserver'
#    elsif first_mounted_archive.database_type == "MySQL"
#      adapter = 'mysql2'
#    end
#    establish_connection(
#    :adapter  => adapter,
#    :host     => first_mounted_archive.Server,
#    :username => first_mounted_archive.Login,
#    :password => first_mounted_archive.Password,
#  #    :password => mounted_archive.decrypted_password,
#    :database => first_mounted_archive.Archive
#    )
#  end
#end
#
#class ImageArchive2 < Image
#  if MountedArchive.all.count >= 2
#    second_mounted_archive = MountedArchive.limit(1).offset(1).first
#    if second_mounted_archive.database_type == "SQL"
#      adapter = 'sqlserver'
#    elsif second_mounted_archive.database_type == "MySQL"
#      adapter = 'mysql2'
#    end
#    establish_connection(
#    :adapter  => adapter,
#    :host     => second_mounted_archive.Server,
#    :username => second_mounted_archive.Login,
#    :password => second_mounted_archive.Password,
#  #    :password => mounted_archive.decrypted_password,
#    :database => second_mounted_archive.Archive
#    )
#  end
#end