class ShipmentFile < ActiveRecord::Base
  
  mount_uploader :file, ImageFileUploader
  
  belongs_to :user
  belongs_to :shipment
  belongs_to :blob
  
  after_commit :sidekiq_blob_and_shipment_creation, :on => :create # To circumvent "Can't find ModelName with ID=12345" Sidekiq error, use after_commit
  
  validates :ticket_number, presence: true
#  validates :event_code, presence: true
  
  attr_accessor :process # Virtual attribute to determine if ready to process versions
  
  
  #############################
  #     Instance Methods      #
  ############################
  
  def default_name
    self.name ||= File.basename(file_url, '.*').titleize
  end
  
  def sidekiq_blob_and_shipment_creation
    ShipmentBlobWorker.perform_async(self.id) # Create the shipment record and the blob in the background
  end
  
  #############################
  #     Class Methods      #
  #############################
end
