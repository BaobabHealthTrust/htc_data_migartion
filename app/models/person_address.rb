class PersonAddress < ActiveRecord::Base
  establish_connection :htc_module
  self.table_name = 'person_address'
end
