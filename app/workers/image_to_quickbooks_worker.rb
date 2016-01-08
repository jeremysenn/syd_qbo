class ImageToQuickbooksWorker
  include Sidekiq::Worker
  
#  def perform(image_file_id)
  def perform(image_file_id, access_token, access_secret)

    image_file = ImageFile.find(image_file_id)
    
    ### Start Copying Image to Quickbooks ###
    oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, access_token, access_secret)
    upload_service = Quickbooks::Service::Upload.new(company_id: image_file.location, access_token: oauth_client)
    
    entity = Quickbooks::Model::BaseReference.new
    entity.type  = image_file.quickbooks_expense_type
    entity.value = image_file.quickbooks_expense_id

    meta = Quickbooks::Model::Attachable.new
    meta.file_name      = "#{image_file.quickbooks_expense_type}_#{image_file.ticket_number}_#{image_file.id}.jpeg"
    meta.content_type   = "image/jpeg"
    meta.note = "#{image_file.quickbooks_expense_type} #{image_file.ticket_number} - #{image_file.id}"
    meta.attachable_ref = Quickbooks::Model::AttachableRef.new(entity)
    
    upload_service.upload(image_file.file.path, "image/jpeg", meta)
    ### End Copying Image to Quickbooks ###
    
  end
  
end