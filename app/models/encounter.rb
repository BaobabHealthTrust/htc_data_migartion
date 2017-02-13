class Encounter < ActiveRecord::Base
  establish_connection :htc_module
  self.table_name = 'encounter'
end
