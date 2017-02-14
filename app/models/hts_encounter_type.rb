class HtsEncounterType < ActiveRecord::Base 
  establish_connection :hts
  self.table_name = "encounter_type"
end
