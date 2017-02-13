def start
  encounters = Encounter.all

  encounters.each do |encounter|

    enc_id = encounter['encounter_id']
    enc_type = encounter['encounter_type']
    enc_patient_id = encounter['patient_id']
    enc_location_id = encounter['location_id']
    enc_form_id = encounter['form_id']
    enc_datetime = encounter['encounter_datetime']
    enc_creator = encounter['creator']
    enc_date_created = encounter['date_created']
    enc_voided = encounter['voided']
    enc_voided_by = encounter['voided_by']
    enc_date_voided = encounter['date_voided']
    enc_void_reason = encounter['void_reason']
    enc_uuid = encounter['uuid']
    enc_changed_by = encounter['changed_by']
    enc_date_changed = encounter['date_changed']
    enc_visit_id = encounter['visit_id']


    enc_concept_map = {
        "PRE TEST COUNSELLING" => ["HTC access type","last hiv test","HIV test date","client risk category","Partner or spouse"]
      }
      puts enc_concept_map.key("HTC access type")

    obs = Observation.find_by_sql("select * from obs where encounter_id = #{enc_id}")
    #puts obs.inspect
    obs.each do |ob|
      puts "#{enc_id}...#{EncounterType.find_by_encounter_type_id(enc_type).name}>>>>>>>>#{ob['obs_id']}...#{ConceptName.find_by_concept_id(ob['concept_id']).name}"
    end

  end

end

start
