class ConceptName < ActiveRecord::Base
  establish_connection :htc_module
  self.table_name = "concept_name"
end
