class Contract < ActiveRecord::Base
#  new columns need to be added here to be writable through mass assignment
#  attr_accessible :tableName, :FieldName, :LookupDisplay, :LookupValue, :IsRequired, :lookupID, :MobileFlag

  establish_connection :jpegger

  self.primary_key = 'contract_id'

end

