class HtsPatientIdentifierType < ActiveRecord::Base

  establish_connection :hts

  self.table_name = "patient_identifier_type"

end
