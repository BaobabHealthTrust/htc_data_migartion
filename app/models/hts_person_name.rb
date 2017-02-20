class HtsPersonName < ActiveRecord::Base
  
  establish_connection :hts

  self.table_name = "person_name"

end
