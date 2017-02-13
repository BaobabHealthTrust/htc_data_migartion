class Patient < ActiveRecord::Base
  establish_connection :htc_module
  self.table_name = 'patient'
end
