class Device < ActiveRecord::Base
  
  establish_connection :tud_config
  
  self.primary_key = 'DevID'
  self.table_name = 'Device'
  
  #############################
  #     Instance Methods      #
  ############################
  
  def scale_read
    xml_string = "<?xml version='1.0' encoding='UTF-8'?>
      <SOAP-ENV:Envelope xmlns:SOAP-ENV='http://schemas.xmlsoap.org/soap/envelope/' xmlns:mime='http://schemas.xmlsoap.org/wsdl/mime/' xmlns:ns1='urn:TUDIntf' xmlns:soap='http://schemas.xmlsoap.org/wsdl/soap/' xmlns:soapenc='http://schemas.xmlsoap.org/soap/encoding/' xmlns:tns='http://tempuri.org/' xmlns:xs='http://www.w3.org/2001/XMLSchema' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'>
         <SOAP-ENV:Body>
            <mns:ReadScale xmlns:mns='urn:TUDIntf-ITUD' SOAP-ENV:encodingStyle='http://schemas.xmlsoap.org/soap/encoding/'>
               <WorkstationIP xsi:type='xs:string'>192.168.111.150</WorkstationIP>
               <WorkstationPort xsi:type='xs:int'>#{self.LocalListenPort}</WorkstationPort>
               <ConsecReads xsi:type='xs:int'>5</ConsecReads>
            </mns:ReadScale>
         </SOAP-ENV:Body>
      </SOAP-ENV:Envelope>"
    client = Savon.client(wsdl: "http://personalfinancesystem.com/tudauth/tudauth.dll/wsdl/ITUD")
    response = client.call(:encode, xml: xml_string)
    data = response.to_hash
    return data[:read_scale_response][:return]
  end
  
  def scale_camera_trigger(ticket_number, weight, location)
    xml_string = "<SOAP-ENV:Envelope xmlns:SOAP-ENV='http://schemas.xmlsoap.org/soap/envelope/' xmlns:mime='http://schemas.xmlsoap.org/wsdl/mime/' xmlns:soap='http://schemas.xmlsoap.org/wsdl/soap/' xmlns:soapenc='http://schemas.xmlsoap.org/soap/encoding/' xmlns:tns='http://tempuri.org/' xmlns:xs='http://www.w3.org/2001/XMLSchema' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'>
      <SOAP-ENV:Body>
         <mns:JpeggerTrigger xmlns:mns='urn:JpeggerTriggerIntf-IJpeggerTrigger' SOAP-ENV:encodingStyle='http://schemas.xmlsoap.org/soap/encoding/'>
            <Host xsi:type='xs:string'>127.0.0.1</Host>
            <Port xsi:type='xs:int'>3333</Port>
            <Trigger xsi:type='xs:string'>
               <CAPTURE>
                  <TICKET_NBR>#{ticket_number}</TICKET_NBR>
                  <CAMERA_NAME>NFSCALE</CAMERA_NAME>
                  <WEIGHT>#{weight}</WEIGHT>
                  <LOCATION>#{location}</LOCATION>
               </CAPTURE>
            </Trigger>
         </mns:JpeggerTrigger>
      </SOAP-ENV:Body>
    </SOAP-ENV:Envelope>"
    client = Savon.client(wsdl: "http://personalfinancesystem.com/jpeggertrigger.dll/wsdl/IJpeggerTrigger")
    client.call(:jpegger_trigger, xml: xml_string)
  end
  
  def scale?
    self.DeviceType == 21
  end
  
  def camera?
    self.DeviceType == 5
  end
  
  #############################
  #     Class Methods      #
  #############################
  
  
end

