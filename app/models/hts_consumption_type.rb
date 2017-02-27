class HtsConsumptionType < ActiveRecord::Base

  establish_connection :hts_inventory

  self.table_name = "consumption_type"

end
