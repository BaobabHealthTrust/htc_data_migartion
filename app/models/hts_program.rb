
class HtsProgram < ActiveRecord::Base
  establish_connection :hts
  self.table_name = "program"
end
