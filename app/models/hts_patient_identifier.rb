class HtsPatientIdentifier < ActiveRecord::Base

  establish_connection :hts

  self.table_name = "patient_identifier"

end
