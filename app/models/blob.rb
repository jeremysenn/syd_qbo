class Blob < ActiveRecord::Base
  #  new columns need to be added here to be writable through mass assignment
#  attr_accessible :jpeg_image, :preview, :sys_date_time, :blob_id

  establish_connection :jpegger
  
  self.primary_key = 'blob_id'

  has_one :image
  
  def self.mounted_archives_preview(id)
    # Search through the mounted archives if any exists
    if (MountedArchive.count > 0)
      MountedArchive.all.each do |mounted_archive|
        blob_class = create_blob_archive_subclass(mounted_archive)
        blob = blob_class.find(id)
        unless blob.blank?
          return blob.preview
          break
        end
      end
    else
      return nil
    end
  end
  
  def self.mounted_archives_jpeg_image(id)
    # Search through the mounted archives if any exists
    if (MountedArchive.count > 0)
      MountedArchive.all.each do |mounted_archive|
        blob_class = create_blob_archive_subclass(mounted_archive)
        blob = blob_class.find(id)
        unless blob.blank?
          return blob.jpeg_image
          break
        end
      end
    else
      return nil
    end
  end
  
  def self.create_blob_archive_subclass(mounted_archive)
    Class.new(super_class = Blob) do
      def self.name
        "DynamicMountedArchiveBlobModel"
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

end
