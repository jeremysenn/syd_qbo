class LookupDef < ActiveRecord::Base
#  new columns need to be added here to be writable through mass assignment
#  attr_accessible :tableName, :FieldName, :LookupDisplay, :LookupValue, :IsRequired, :lookupID, :MobileFlag

  establish_connection :jpegger

  self.table_name = 'lookupDefs'
  self.primary_key = 'lookupID'

  def self.image_event_codes
    LookupDef.where(tableName: 'images', FieldName: 'event_code')
  end

  def self.shipment_event_codes
    LookupDef.where(tableName: 'shipments', FieldName: 'event_code')
  end
  
  def self.cust_pic_event_codes
    LookupDef.where(tableName: 'cust_pics', FieldName: 'event_code')
  end

  def self.image_locations
    LookupDef.where(tableName: 'images', FieldName: 'location')
  end

  def self.shipment_locations
    LookupDef.where(tableName: 'shipments', FieldName: 'location')
  end

  def self.image_camera_names
    LookupDef.where(tableName: 'images', FieldName: 'camera_name')
  end

  def self.shipment_camera_names
    LookupDef.where(tableName: 'shipments', FieldName: 'camera_name')
  end

  ### SEARCH WITH RANSACK ###
  def self.ransack_search(query)
    search = LookupDef.ransack(query)
    lookup_defs = search.result

    return lookup_defs
  end

end

