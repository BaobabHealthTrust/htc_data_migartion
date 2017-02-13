class Observation < ActiveRecord::Base
  establish_connection :htc_module
  self.table_name = 'obs'
end
