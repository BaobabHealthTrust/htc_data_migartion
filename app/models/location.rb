class Location < ActiveRecord::Base

  establish_connection :htc_module

  self.table_name = "location"

end
