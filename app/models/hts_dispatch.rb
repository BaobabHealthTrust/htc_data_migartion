class HtsDispatch < ActiveRecord::Base

  establish_connection :hts_inventory

  self.table_name = "dispatch"

end
