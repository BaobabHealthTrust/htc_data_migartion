class HtsForm < ActiveRecord::Base
  establish_connection :hts
  self.table_name = "form"
end
