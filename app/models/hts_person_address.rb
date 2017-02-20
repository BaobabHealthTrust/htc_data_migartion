class HtsPersonAddress < ActiveRecord::Base

  establish_connection :hts

  self.table_name = "person_address"
  
end
