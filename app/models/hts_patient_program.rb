class HtsPatientProgram < ActiveRecord::Base
  establish_connection :hts
  self.table_name = "patient_program"
end
