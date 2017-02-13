class EncounterType < ActiveRecord::Base
  establish_connection :htc_module
  self.table_name = "encounter_type"
end
