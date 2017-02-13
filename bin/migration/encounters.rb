Assessment_encounter = EncounterType.find_by_name('assessment')
Update_hiv_status_encounter = EncounterType.find_by_name('UPDATE HIV STATUS')


def start
  obs_sql_statement =  "INSERT INTO obs (obs_id,person_id,concept_id,encounter_id,order_id,obs_datetime,"
  obs_sql_statement += "location_id,obs_group_id,accession_number,value_group_id,value_boolean,value_coded,"
  obs_sql_statement += "value_coded_name_id,value_drug,value_datetime,value_numeric,value_modifier,value_text,"
  obs_sql_statement += "date_started,date_stopped,comments,creator,date_created,voided,voided_by,date_voided,"
  obs_sql_statement += "void_reason,value_complex,uuid) VALUES "

  @@concept_mapping = {
      "HTC access type" => ["HTS Access type","PRE TEST COUNSELLING"],
      "last hiv test" => ["Last HIV test","PRE TEST COUNSELLING"],
      "HIV test date" => ["Time Since Last Test Date","PRE TEST COUNSELLING"],
      "client risk category" => ["Client Risk Category","PRE TEST COUNSELLING"],
      "Partner or spouse" => ["Do you have a partner?","PRE TEST COUNSELLING"]
    }
  #`cd #{File_destination} && touch observations.sql`
  #`echo -n '#{obs_sql_statement}' < #{File_destination}/observations.sql`

  #self.create_pretest_counselling_enc
  #self.create_hiv_testing_enc
  obs = Observation.all

  obs.each do |ob|
    obs_id = ob['obs_id']
    person_id = ob['person_id']
    concept_id = get_concept_id(ob['concept_id'])
    concept_id = concept_id[0] rescue nil

    encounter_id = ob['concept_id']
    order_id = ob['order_id']
    obs_datetime = ob['obs_datetime']
    location_id = ob['location_id']
    obs_group_id = ob['obs_group_id']
    accession_number = ob['accession_number']
    value_group_id = ob['value_group_id']
    value_boolean = ob['value_boolean']
    value_coded = get_new_value_coded(ob['value_coded'])
    value_coded_name_id = ob['value_coded_name_id']
    value_drug = ob['value_drug']
    value_datetime = ob['value_datetime']
    value_numeric = ob['value_numeric']
    value_modifier = ob['value_modifier']
    value_text = ob['value_text']
    value_complex = ob['value_complex']
    comments = ob['comments']
    creator = ob['creator']
    date_created = ob['date_created']
    voided = ob['voided']
    voided_by = ob['voided_by']
    date_voided = ob['date_voided']
    void_reason = ob['void_reason']
  
    uuid = ActiveRecord::Base.connection.select_one <<EOF
        select uuid()
EOF


    obs_sql =  "(\"#{obs_id}\",\"#{person_id}\",\"#{concept_id}\",\"#{encounter_id}\",\"#{order_id}\",\"#{obs_datetime}\","
    obs_sql += "\"#{location_id}\",\"#{obs_group_id}\",\"#{accession_number}\",\"#{value_group_id}\",\"#{value_boolean}\",\"#{value_coded}\","
    obs_sql += "\"#{value_coded_name_id}\",\"#{value_drug}\",\"#{value_datetime}\",\"#{value_numeric}\",\"#{value_modifier}\",\"#{value_text}\","
    obs_sql += "\"#{}\",\"#{}\",\"#{comments}\",\"#{creator}\",\"#{date_created}\",\"#{voided}\",\"#{voided_by}\",\"#{date_voided}\","
    obs_sql += "\"#{void_reason}\",\"#{value_complex}\",\"#{uuid.values.first}\"),"

    puts "#{obs_sql}"
  end

end

def get_new_value_coded(value)
  if value.blank?
    return
  end
  concept_name = ConceptName.find_by_concept_id(value).name
  return concept_name
end

def get_concept_id(concept_id)
  if concept_id.blank?
    return
  end

  concept_name = ConceptName.find_by_concept_id(concept_id).name
  new_concept_name = @@concept_mapping[concept_name]
  return new_concept_name

end

def self.create_pretest_counselling_enc

  pretest_counselling_map = {
      "HTC access type" => 'HTS Access type',
      "last hiv test" => 'Last HIV test',
      "ot collected" => 'Time Since Last Test',
      "HIV test date" => 'Time Since Last Test Date',
      "client risk category" => 'Client Risk Category',
      "Partner or spouse" => 'Do you have a partner?',
      "Not collected" => 'Event in the last 72 hrs?'
    }
  
  access_type = {
      "Routine HTC with health service" => 'Routine HTS (PITC) within Health Service',
      "Comes with HTC family Ref slip" => 'Comes with HTS Family Reference Slip',
      "Other" => 'Other'
    }
  
  assessment_encounter = EncounterType.find_by_name('assessment')
  
  obs = Observation.all

  obs.each do |ob|
    obs_id = ob['obs_id']
    person_id = ob['person_id']
    concept_id = ob['concept_id']
    obs_encounter_id = ob['encounter_id']
    concept_name = ConceptName.find_by_concept_id(concept_id).name
    #puts "#{concept_name} >>>>>>>>>>>> #{pretest_counselling_map[concept_name]}" if !pretest_counselling_map[concept_name].blank?
    new_concept_id = HtsConceptName.find_by_name(pretest_counselling_map[concept_name]).concept_id rescue nil
    #puts "#{concept_id} >>>>>>>>>>>>>> #{new_concept_id}" if !new_concept_id.blank?
    sql_statement = "(#{obs_id},#{person_id},#{new_concept_id},"

    encounter_id = Encounter.find_by_encounter_id(obs_encounter_id).encounter_type
    encounter_type = EncounterType.find_by_encounter_type_id(encounter_id).name rescue nil
    puts "#{encounter_type}"
=begin
    case concept_name
      when 'HTC access type'
        v_coded = ob['value_coded']
        access_type = ConceptName.find_by_concept_id(v_coded).name
        new_access_type = access_type[access_type]
        new_v_coded = HtsConceptName.find_by_name(new_access_type).concept_id rescue nil
        sql_statement += "\"#{new_v_coded}\", \"\",\"\",\"\",\"\",\"\",\"\")"
      when 'last hiv test'
        v_coded = ob['value_coded']
        last_hiv_test = ConceptName.find_by_concept_id(v_coded).name rescue nil
        #new_last_hiv_test = last_test[last_hiv_test]
        new_v_coded = HtsConceptName.find_by_name(last_hiv_test).concept_id rescue nil
        sql_statement += "#{new_v_coded}, \"\",\"\",\"\",\"\",\"\",\"\")"
      when 'HIV test date'
        v_datetime = ob['value_datetime']
        sql_statement += "\"\",\"\",\"\",\"#{v_datetime}\",\"\",\"\",\"\")"
      when 'client risk category'
        v_text = ob['value_text']
        sql_statement += "\"\",\"\",\"\",\"\",\"\",\"\",\"#{v_text}\")"
      when 'Partner or spouse'
        v_coded = ob['value_coded']
        partner = ConceptName.find_by_concept_id(v_coded).name rescue nil
        new_v_coded = HtsConceptName.find_by_name(partner).concept_id rescue nil
        sql_statement += "#{new_v_coded}, \"\",\"\",\"\",\"\",\"\",\"\")"
    end
    puts "#{sql_statement}"
=end
  end
end

def create_hiv_testing_enc
  
  hiv_testing_obs_map = {
      "HTC Test 1 name" => 'First Pass Test Kit 1 Name',
      "HTC Test 1 result" => 'First Pass Test 1 Result',
      "HTC Test 2 name" => 'First Pass Test Kit 2 Name',
      "test 2 lot number" => 'First Pass Test Kit 2 Lot Number',
      "HTC Test 2 result" => 'First Pass Test 2 Result',
      "HTC Test 1 Time frame" => 'First Pass Test Kit 1 Testing Duration (Minutes)',
      "HTC Test 2 Time frame" => 'First Pass Test Kit 2 Testing Duration (Minutes)',
      "Result of HIV test" => 'Result Given to Client',
      "test 1 lot number" => 'First Pass Test Kit 1 Lot Number'
    }
  
  obs = Observation.all

  obs.each do |ob|
  end

end

start
