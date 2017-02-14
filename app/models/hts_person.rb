class HtsPerson < ActiveRecord::Base
  establish_connection :hts
  self.table_name = "person"
end
