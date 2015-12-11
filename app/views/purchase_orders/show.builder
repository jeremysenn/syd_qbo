xml.LeadsOnlineUpload do
  xml.software do
    xml.name("Scrap Yard Dog")
    xml.version("1.0")
  end
  xml.store_info do
    xml.company_nm(@company_info.company_name)
    xml.store_number(current_company.CompanyID)
    xml.store_nm("Tranact Test Store (JPEGger)")
    xml.store_addr1(@company_info.company_address.line1)
    xml.store_city(@company_info.company_address.city)
    xml.store_state(@company_info.company_address.country_sub_division_code)
    xml.store_zip(@company_info.company_address.postal_code)
    xml.store_phone(@company_info.primary_phone.free_form_number)
  end
  xml.tickets do
    xml.ticket do
      xml.ticket_number(@doc_number)
      xml.enter_date(@purchase_order.txn_date)
      xml.clerk(current_user.email)
      xml.void("N")
    end
    xml.customer do
      xml.cust_nm_last(@vendor.family_name)
      xml.cust_nm_first(@vendor.given_name)
      xml.cust_nm_middle
      xml.cust_nm_suffix
      xml.cust_addr1>1711 28TH AVE N
      xml.cust_addr2/>
      xml.cust_city>ST PETERSBURG
      xml.cust_state>FL
      xml.cust_zip>33713--413
      xml.cust_phone>(727) 741-1423
      xml.cust_id_type>DL
      xml.cust_id_state>FL
      xml.cust_id_number>12345678
      xml.cust_id_exp>2018-02-28T00:00:00
      xml.cust_birthdate>1970-02-28T00:00:00
      xml.cust_weight>200
      xml.cust_height>6'1"
      xml.cust_eye>Brown
      xml.cust_hair>Bald
      xml.cust_race>W
      xml.cust_sex>M
      xml.cust_info/>
      xml.cust_picture code="C"/>
      xml.cust_picture code="I"/>
      xml.cust_picture code="T"/>
      xml.cust_picture code="S"/>
      xml.employer_nm/>
      xml.employer_addr1/>
      xml.employer_addr2/>
      xml.employer_city/>
      xml.employer_state/>
      xml.employer_zip/>
      xml.employer_phone/>
    end
  end
end