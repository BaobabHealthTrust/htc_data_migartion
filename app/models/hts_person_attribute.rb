class HtsPersonAttribute < ActiveRecord::Base
  establish_connection :hts
  self.table_name = "person_attribute"
end
