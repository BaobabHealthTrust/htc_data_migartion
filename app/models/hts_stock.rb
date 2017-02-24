class HtsStock < ActiveRecord::Base

  establish_connection :hts_inventory

  self.table_name = "stock"

end
