class Kits < ActiveRecord::Base
  establish_connection :htc_module
  self.table_name = "kits"
end
