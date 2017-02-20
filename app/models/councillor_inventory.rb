class Councillor_inventory < ActiveRecord::Base
  establish_connection :htc_module
  self.table_name = "councillor_inventory"
end
