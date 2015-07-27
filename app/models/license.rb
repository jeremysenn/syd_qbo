class License < ActiveRecord::Base
  
  #############################
  #     Instance Methods      #
  ############################
  
  #############################
  #     Class Methods      #
  #############################
  
  def self.valid?
    License.first.license_valid?
  end
  
  def self.dog_license_check
    require 'net/http'
    license = License.first
    
    unless ENV["JPEGGER_SERVICE"].blank?
      uri = URI("http://#{ENV['JPEGGER_SERVICE']}:3333/checkdoglicense.html?numusers=#{User.count}")
      response =  Net::HTTP.get(uri)
      if response == "<html><body>OK</body></html>\r\n"
        license.license_valid = true
      else
        license.license_valid = false
      end
      license.save
    end
    
  end

end

