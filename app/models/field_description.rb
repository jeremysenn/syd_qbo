class FieldDescription < ActiveRecord::Base

  establish_connection :jpegger

  self.table_name = 'FieldDescriptions'
#  self.primary_key = 'lookupID'

end

