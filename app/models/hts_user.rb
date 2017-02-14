class HtsUser < ActiveRecord::Base
  establish_connection :hts
  self.table_name = "users"
end
