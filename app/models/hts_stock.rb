class HtsStock < ActiveRecord::Base

  establish_conection :hts_inventory

  self.table_name = "stock"

end
