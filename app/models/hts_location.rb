class HtsLocation < ActiveRecord::Base
  establish_connection :hts
  self.table_name = "location"
end 
