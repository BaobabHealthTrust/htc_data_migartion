class PatientIdentifierType < ActiveRecord::Base

  establish_connection :htc_module

  self.table_name = "patient_identifier_type"

end
