xml.instruct!
xml.import(:xmlns => "RAPIDv2.1") do
  xml.user(:username => 'JSenn', :password => 'bwidemo')
  xml.shop(:id => "999") do
    xml.name("BWDEMO")
  end
  xml.date(DateTime.now)
  xml.transaction(:transid => @doc_number, :transtype => 'B') do
    xml.date("#{@purchase_order.txn_date}T00:00:00Z")
    xml.declaration
    xml.employee do
      xml.name(current_user.email)
    end
    xml.customer(:id => @customer.vendorid) do
      xml.lname(@customer.last_name)
      xml.middlename(@customer.middle_name)
      xml.fname(@customer.first_name)
      xml.initials
      unless @customer.dob.blank?
        xml.birthdate(@customer.dob)
      else
        xml.birthdate('1970-01-01')
      end
      xml.gender(@customer.sex)
      #xml.height(@customer.height)
      xml.weight(@customer.weight)
      unless @customer.eye_color.blank?
        xml.eyecolor(@customer.eye_color)
      end
      unless @customer.hair_color.blank?
        xml.haircolor(@customer.hair_color)
      else
        xml.haircolor('Unknown')
      end
      xml.vehiclemaker
      xml.vehiclemodel
      xml.vehiclecolor
      xml.street(@customer.address1)
      xml.city(@customer.city)
      xml.prov(@customer.state)
      xml.postalcode(@customer.zip)
      xml.phone(@customer.primary_phone)
      xml.workphone(@customer.employer_phone)
      xml.id1type("DL")
      xml.id1(@customer.license_number)
      xml.id1issuer(0)
      xml.id1image
      xml.id2type
      xml.id2
      xml.id2issuer
      xml.id2image
      xml.identification(:type => "1")
      xml.identification(:type => "1")
      xml.customerpicture
      xml.signature
    end
    @purchase_order.line_items.each do |line_item|
      xml.item do
        xml.description(@item_service.fetch_by_id(line_item.item_based_expense_line_detail.item_ref).name)
        xml.serial
        xml.class
        xml.make
        xml.model
        xml.size
        xml.color
        xml.engravings
        xml.quantity(line_item.item_based_expense_line_detail.quantity.to_i)
        xml.price(line_item.amount)
        xml.itempicture
#        xml.vehicleregstateid
        xml.vehicletitlenumber
      end
    end
  end
end