class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
       
  has_many :image_files
  has_many :shipment_files
  has_one :user_setting
  
  after_commit :create_user_settings, :on => :create
  
  #############################
  #     Instance Methods      #
  ############################
  
  def create_user_settings
    UserSetting.create(user_id: id)
  end
  
  def show_thumbnails?
    user_setting.show_thumbnails?
  end
  
  def images_table?
    user_setting.table_name == "images"
  end
  
  def shipments_table?
    user_setting.table_name == "shipments"
  end
  
  #############################
  #     Class Methods      #
  #############################
  
  def self.dog_licensing_ok?
    require 'net/http'
    
    unless ENV["JPEGGER_SERVICE"].blank?
      uri = URI("http://#{ENV['JPEGGER_SERVICE']}:3333/checkdoglicense.html?numusers=#{User.count + 1}")
      response =  Net::HTTP.get(uri)
      return response == "<html><body>OK</body></html>\r\n"
    else
      return true
    end
    
#    unless ENV["JPEGGER_SERVICE"].blank?
#      return system("curl http://#{ENV['JPEGGER_SERVICE']}:3333/checkdoglicense.html?numusers=#{User.count + 1}")
#    else
#      return true
#    end
  end
end
