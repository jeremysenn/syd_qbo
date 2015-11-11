class Device < ActiveRecord::Base
  
  establish_connection :tud_config
  
  self.primary_key = 'DevID'
  self.table_name = 'Device'
  
  belongs_to :company, foreign_key: "CompanyID"
  belongs_to :workstation, foreign_key: "WorkstationID"
#  has_many :device_group_members
  
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
  
  def scale_camera_trigger(ticket_number, event_code, commodity_name, location, weight)
    xml_string = "<SOAP-ENV:Envelope xmlns:SOAP-ENV='http://schemas.xmlsoap.org/soap/envelope/' xmlns:mime='http://schemas.xmlsoap.org/wsdl/mime/' xmlns:soap='http://schemas.xmlsoap.org/wsdl/soap/' xmlns:soapenc='http://schemas.xmlsoap.org/soap/encoding/' xmlns:tns='http://tempuri.org/' xmlns:xs='http://www.w3.org/2001/XMLSchema' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'>
      <SOAP-ENV:Body>
         <mns:JpeggerTrigger xmlns:mns='urn:JpeggerTriggerIntf-IJpeggerTrigger' SOAP-ENV:encodingStyle='http://schemas.xmlsoap.org/soap/encoding/'>
            <Host xsi:type='xs:string'>127.0.0.1</Host>
            <Port xsi:type='xs:int'>3333</Port>
            <Trigger xsi:type='xs:string'>
               <CAPTURE>
                  <TICKET_NBR>#{ticket_number}</TICKET_NBR>
                  <EVENT_CODE>#{event_code}</EVENT_CODE>
                  <CMDY_NAME>#{commodity_name}</CMDY_NAME>
                  <CAMERA_NAME>#{self.DeviceName}</CAMERA_NAME>
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
  
  def drivers_license_scan
    xml_string = "<?xml version='1.0' encoding='UTF-8'?>
      <SOAP-ENV:Envelope xmlns:SOAP-ENV='http://schemas.xmlsoap.org/soap/envelope/' xmlns:mime='http://schemas.xmlsoap.org/wsdl/mime/' xmlns:ns1='urn:TUDIntf' xmlns:soap='http://schemas.xmlsoap.org/wsdl/soap/' xmlns:soapenc='http://schemas.xmlsoap.org/soap/encoding/' xmlns:tns='http://tempuri.org/' xmlns:xs='http://www.w3.org/2001/XMLSchema' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'>
         <SOAP-ENV:Body>
            <mns:ReadID xmlns:mns='urn:TUDIntf-ITUD' SOAP-ENV:encodingStyle='http://schemas.xmlsoap.org/soap/encoding/'>
               <WorkstationIP xsi:type='xs:string'>192.168.111.150</WorkstationIP>
               <WorkstationPort xsi:type='xs:int'>#{self.LocalListenPort}</WorkstationPort>
               <Fields xsi:type='soapenc:Array' soapenc:arrayType='ns1:TTUDField[2]'>
                  <item xsi:type='ns1:TTUDField'>
                     <FieldName xsi:type='xs:string' />
                     <FieldValue xsi:type='xs:string' />
                  </item>
                  <item xsi:type='ns1:TTUDField'>
                     <FieldName xsi:type='xs:string' />
                     <FieldValue xsi:type='xs:string' />
                  </item>
               </Fields>
            </mns:ReadID>
         </SOAP-ENV:Body>
      </SOAP-ENV:Envelope>"
    client = Savon.client(wsdl: "http://personalfinancesystem.com/tudauth/tudauth.dll/wsdl/ITUD")
    response = client.call(:encode, xml: xml_string)
    data = response.to_hash
    return Hash.from_xml(data[:read_id_response][:return])["response"]
  end
  
  def drivers_license_camera_trigger(customer_first_name, customer_last_name, customer_number, license_number, license_issue_date, license_expiration_date, dob, sex, event_code, location, address1, city, state, zip)
    xml_string = "<SOAP-ENV:Envelope xmlns:SOAP-ENV='http://schemas.xmlsoap.org/soap/envelope/' xmlns:mime='http://schemas.xmlsoap.org/wsdl/mime/' xmlns:soap='http://schemas.xmlsoap.org/wsdl/soap/' xmlns:soapenc='http://schemas.xmlsoap.org/soap/encoding/' xmlns:tns='http://tempuri.org/' xmlns:xs='http://www.w3.org/2001/XMLSchema' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'>
      <SOAP-ENV:Body>
         <mns:JpeggerTrigger xmlns:mns='urn:JpeggerTriggerIntf-IJpeggerTrigger' SOAP-ENV:encodingStyle='http://schemas.xmlsoap.org/soap/encoding/'>
            <Host xsi:type='xs:string'>127.0.0.1</Host>
            <Port xsi:type='xs:int'>3333</Port>
            <Trigger xsi:type='xs:string'>
               <CAPTURE>
                  <TABLE>cust_pics</TABLE>
                  <CAMERA_NAME>#{self.DeviceName}</CAMERA_NAME>
                  <FIRST_NAME>#{customer_first_name}</FIRST_NAME>
                  <LAST_NAME>#{customer_last_name}</LAST_NAME>
                  <CUST_NBR>#{customer_number}</CUST_NBR>
                  <DOB>#{dob}</DOB>
                  <SEX>#{sex}</SEX>
                  <ID>#{license_number}</ID>
                  <ISSUE_DATE>#{license_issue_date}</ISSUE_DATE>
                  <EXPIRATION_DATE>#{license_expiration_date}</EXPIRATION_DATE>
                  <EVENT_CODE>#{event_code}</EVENT_CODE>
                  <LOCATION>#{location}</LOCATION>
                  <ADDRESS1>#{address1}</ADDRESS1>
                  <CITY>#{city}</CITY>
                  <STATE>#{state}</STATE>
                  <ZIP>#{zip}</ZIP>
               </CAPTURE>
            </Trigger>
         </mns:JpeggerTrigger>
      </SOAP-ENV:Body>
    </SOAP-ENV:Envelope>"
    client = Savon.client(wsdl: "http://personalfinancesystem.com/jpeggertrigger.dll/wsdl/IJpeggerTrigger")
    client.call(:jpegger_trigger, xml: xml_string)
  end
  
  def drivers_license_scanned_image
    require 'open-uri'
#    open('http://192.168.111.150:10001').read
#    open("http://#{workstation.Host}:#{self.TUDPort}/jpeg.jpg").read
    open('http://192.168.111.149:10018').read # Eseek via proxy
  end
  
  def scale?
    self.DeviceType == 21
  end
  
  def scale_camera_only?
    scale? and self.NoHardware == 1
  end
  
  def camera?
    self.DeviceType == 5
  end
  
  def signature_pad?
    self.DeviceType == 11
  end
  
  def printer?
    self.DeviceType == 20
  end
  
  def crossmatch? # Fingerprint scanner
    self.DeviceType == 12
  end
  
  def device_type_icon
    if scale?
      unless scale_camera_only?
        "<i class='fa fa-dashboard fa-lg'></i>"
      else
        "<i class='fa fa-camera fa-lg'></i>"
      end
    elsif camera?
      "<i class='fa fa-camera fa-lg'></i>"
    elsif signature_pad?
      "<i class='fa fa-pencil fa-lg'></i>"
    elsif printer?
      "<i class='fa fa-print fa-lg'></i>"
    elsif crossmatch?
      "<i class='fa fa-hand-pointer-o fa-lg'></i>"
    else
      ""
    end
  end
  
  def type
    if scale? 
      "Scale"
    elsif camera?
      "Camera"
    elsif signature_pad?
      "Signature Pad"
    elsif printer?
      "Printer"
    elsif crossmatch?
      "Crossmatch"
    else
      "Unknown"
    end
  end
  
  def device_group_members
    DeviceGroupMember.where(DevID: id)
  end
  
  def device_groups
    device_group_members.map{|dgm| dgm.device_group }
  end
  
  def device_group_member_order(device_group_id)
    device_group_member = DeviceGroupMember.find_by_DeviceGroupID_and_DevID(device_group_id, id)
    unless device_group_member.blank?
      device_group_member.DevOrder
    else
      nil
    end
  end
  
  #############################
  #     Class Methods      #
  #############################
  
  
end

