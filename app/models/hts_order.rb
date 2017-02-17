class HtsOrder < ActiveRecord::Base
  establish_connection :hts
  self.table_name = "orders"
end
