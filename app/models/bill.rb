class Bill < ActiveRecord::Base
  
  #############################
  #     Instance Methods      #
  ############################
  
  #############################
  #     Class Methods      #
  #############################
  
  def self.create_from_purchase_order(purchase_order_service, bill_service, purchase_order)
    @purchase_order = purchase_order
    @bill = Quickbooks::Model::Bill.new
    @bill.vendor_id = @purchase_order.vendor_ref
    @bill.doc_number = @purchase_order.doc_number
    
    @purchase_order.line_items.each do |line_item|
      item_based_expense_line_detail = Quickbooks::Model::ItemBasedExpenseLineDetail.new
      item_based_expense_line_detail.unit_price = line_item.item_based_expense_line_detail.unit_price
      item_based_expense_line_detail.quantity = line_item.item_based_expense_line_detail.quantity
      item_based_expense_line_detail.item_id= line_item.item_based_expense_line_detail.item_ref

      bill_line_item = Quickbooks::Model::BillLineItem.new
      bill_line_item.detail_type = "ItemBasedExpenseLineDetail"
      bill_line_item.item_based_expense_line_detail = item_based_expense_line_detail
      bill_line_item.amount = line_item.amount
      bill_line_item.description = line_item.description
      @bill.line_items.push(bill_line_item)
    end
    
    @bill = bill_service.create(@bill)
    
    @purchase_order.po_status = "Closed"
    purchase_order_service.update(@purchase_order)
    
    return @bill
  end
  
  def self.generate_xml(bill, company_info, company_id, user, customer, item_service)
    xml = ::Builder::XmlMarkup.new(:indent => 2)
    xml.instruct!
    xml.LeadsOnlineUpload do
      xml.software do
        xml.name("Scrap Yard Dog")
        xml.version("1.0")
      end
      xml.store_info do
        xml.company_nm(company_info.company_name)
        xml.store_number(company_id)
        xml.store_nm("Tranact Test Store (JPEGger)")
        xml.store_addr1(company_info.company_address.line1)
        xml.store_addr2(company_info.company_address.line2)
        xml.store_city(company_info.company_address.city)
        xml.store_state(company_info.company_address.country_sub_division_code)
        xml.store_zip(company_info.company_address.postal_code)
        xml.store_county
        xml.store_phone(company_info.primary_phone.free_form_number)
      end
      xml.tickets do
        xml.ticket do
          xml.ticket_number(bill.doc_number)
          xml.enter_date(bill.txn_date)
          xml.clerk(user.email)
          xml.void("N")
          xml.customer do
            xml.cust_nm_last(customer.last_name)
            xml.cust_nm_first(customer.first_name)
            xml.cust_nm_middle
            xml.cust_nm_suffix
            xml.cust_addr1(customer.address1)
            xml.cust_addr2
            xml.cust_city(customer.city)
            xml.cust_state(customer.state)
            xml.cust_zip(customer.zip)
            xml.cust_phone(customer.primary_phone)
            xml.cust_id_type("DL")
            xml.cust_id_state(customer.state)
            xml.cust_id_number(customer.license_number)
            xml.cust_id_exp(customer.expiration_date)
            xml.cust_birthdate(customer.dob)
            xml.cust_weight(customer.weight)
            xml.cust_height(customer.height)
            xml.cust_eye(customer.eye_color)
            xml.cust_hair(customer.hair_color)
            xml.cust_race
            xml.cust_sex(customer.sex)
            xml.cust_info
            xml.cust_picture(:code => "C")
            xml.cust_picture(:code => "I")
            xml.cust_picture(:code => "T")
            xml.cust_picture(:code => "S")
            xml.employer_nm(customer.employer)
            xml.employer_addr1
            xml.employer_addr2
            xml.employer_city
            xml.employer_state
            xml.employer_zip
            xml.employer_phone(customer.employer_phone)
          end
          xml.vehicle do
            xml.vehicle_license
            xml.vehicle_license_state
            xml.vehicle_license_exp
            xml.vehicle_make
            xml.vehicle_model
            xml.vehicle_year
            xml.vehicle_color
            xml.trailer_desc
            xml.trailer_color
            xml.trailer_license
            xml.trailer_license_state
            xml.trailer_license_exp
            xml.vehicle_picture(:code => "V")
            xml.vehicle_picture(:code => "L")
          end
          xml.property do
            bill.line_items.each do |line_item|
              xml.item do
                xml.item_number(line_item.id)
                xml.item_make
                xml.item_model
                xml.item_serial
                xml.item_color
                xml.item_condition
                xml.item_volts
                xml.item_amps
                xml.item_desc(item_service.fetch_by_id(line_item.item_based_expense_line_detail.item_ref).name)
                xml.item_notes
                xml.item_net_wt(line_item.item_based_expense_line_detail.quantity)
                xml.item_amount(line_item.amount)
                xml.item_received_title("N")
                xml.item_picture(:code => "A")
              end
            end
          end
        end
      end
    end
    
  end
  
end

