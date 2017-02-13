class HtsConceptName < ActiveRecord::Base
  establish_connection :hts
  self.table_name = "concept_name"
end
