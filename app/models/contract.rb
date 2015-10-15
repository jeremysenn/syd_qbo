class Contract < ActiveRecord::Base
  
  validates :name, presence: true
  validates :wording, presence: true
  validates :company_id, presence: true

  #############################
  #     Instance Methods      #
  ############################
  
  
  #############################
  #     Class Methods      #
  #############################
  
end

