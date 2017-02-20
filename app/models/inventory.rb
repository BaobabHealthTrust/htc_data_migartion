class Inventory < ActiveRecord::Base
  establish_connection :htc_module
  self.table_name = "inventory"
end
