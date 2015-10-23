class CustPicFile < ActiveRecord::Base
  
  mount_uploader :file, ImageFileUploader
  
  belongs_to :user
  belongs_to :cust_pic
  belongs_to :blob
  
  after_commit :sidekiq_blob_and_cust_pic_creation, :on => :create # To circumvent "Can't find ModelName with ID=12345" Sidekiq error, use after_commit
  
#  validates :event_code, presence: true
  
  attr_accessor :process # Virtual attribute to determine if ready to process versions
  
  
  #############################
  #     Instance Methods      #
  ############################
  
  def default_name
    self.name ||= File.basename(file_url, '.jpg').titleize
  end
  
  def sidekiq_blob_and_cust_pic_creation
    CustPicBlobWorker.perform_async(self.id) # Create the cust_pic record and the blob in the background
  end
  
  #############################
  #     Class Methods      #
  #############################
end
