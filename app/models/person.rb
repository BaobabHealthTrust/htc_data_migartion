class Person < ActiveRecord::Base
  establish_connection :htc_module
  self.table_name = 'person'
end
