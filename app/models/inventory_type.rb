class InventoryType < ActiveRecord::Base

  establish_connection :htc_module

  self.table_name = "inventory_type"

end
