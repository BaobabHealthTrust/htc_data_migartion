File_destination = '~/'
$concept_map = {
    "HTC access type" => 'HTS Access type',
    "last hiv test" => 'Last HIV test',
    "HIV test date" => 'Time Since Last Test Date',
    "client risk category" => 'Client Risk Category',
    "Partner or spouse" => 'Do you have a partner?',
    "Appointment date" => 'Appointment Date Given',
    "Refer to clinic" => 'Referral for Re-Testing',
    "Patient pregnant" => 'Sex/Pregnancy',
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

$encounter_map = {
      "PRE TEST COUNSELLING" => ["HTS Access type","Last HIV test","Time Since Last Test",
              "Time Since Last Test Date","Client Risk Category","Do you have a partner?",
              "Event in the last 72 hrs?" ],
      "POST TEST COUNSELLING" => ["Referral for Re-Testing","Appointment Date Given",
              "HTS Family Referral Slips","Male condoms","Comments","Female condoms"],
      "HTS CLIENT REGISTRATION" => ["Sex/Pregnancy","Consent given to be contacted?",
              "Contact Detail Type","First name","Last name","Age","Age Group","Year of Birth"],
      "HIV TESTING" => ["First Pass Test Kit 1 Name","First Pass Test 1 Result","First Pass Test Kit 2 Name",
              "First Pass Test Kit 2 Lot Number","First Pass Test 2 Result","Immediate Repeat Test Kit 1 Name",
              "Immediate Repeat Test Kit 2 Name","First Pass Test Kit 1 Testing Duration (Minutes)",
              "First Pass Test Kit 2 Testing Duration (Minutes)","Immediate Repeat Test Kit 1 Testing Duration (Minutes)",
              "Immediate Repeat Test Kit 2 Testing Duration (Minutes)","Outcome Summary","Result Given to Client",
              "Client gives consent to be tested?","First Pass Test Kit 1 Lot Number","Immediate Repeat Tester",
              "Immediate Repeat Test Kit 1 Lot Number","Immediate Repeat Test Kit 2 Lot Number"]
       }

def start

  obs_sql_statement =  "INSERT INTO obs (obs_id,person_id,concept_id,encounter_id,order_id,obs_datetime,"
  obs_sql_statement += "location_id,obs_group_id,accession_number,value_group_id,value_boolean,value_coded,"
  obs_sql_statement += "value_coded_name_id,value_drug,value_datetime,value_numeric,value_modifier,value_text,"
  obs_sql_statement += "date_started,date_stopped,comments,creator,date_created,voided,voided_by,date_voided,"
  obs_sql_statement += "void_reason,value_complex,uuid) VALUES "

  encounter_sql_statement =  "INSERT INTO encounter (encounter_id,encounter_type,patient_id,provider_id,location_id,"
  encounter_sql_statement += "form_id,encounter_datetime,creator,date_created,voided,voided_by,date_voided,void_reason,"
  encounter_sql_statement += "uuid,changed_by,date_changed,patient_program_id) VALUES "

  `cd #{File_destination} && touch observations.sql encounters.sql`
  `echo -n '#{obs_sql_statement}' >> #{File_destination}/observations.sql`
  `echo -n '#{obs_sql_statement}' >> #{File_destination}/observations.sql`

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
    enc_changed_by = encounter['changed_by']
    enc_date_changed = encounter['date_changed']
    enc_visit_id = encounter['visit_id']

    provider_id = 1

    uuid = ActiveRecord::Base.connection.select_one <<EOF
          select uuid()
EOF

    obs = Observation.find_by_sql("select * from obs where encounter_id = #{enc_id}")

    obs.each do |ob|
      
      obs_id = ob['obs_id']
      person_id = ob['person_id']
      order_id = ob['order_id']
      obs_datetime = ob['obs_datetime']
      location_id = ob['location_id']
      obs_group_id = ob['obs_group_id']
      accession_number = ob['accession_number']
      value_group_id = ob['value_group_id']
      value_boolean = ob['value_boolean']

      concept_name = ConceptName.find_by_concept_id(ob['concept_id']).name
      new_concept_name = $concept_map[concept_name]
      puts "#{new_concept_name}"
      concept_id = HtsConceptName.find_by_name(new_concept_name).concept_id rescue nil
      
      if $encounter_map["PRE TEST COUNSELLING"].include? new_concept_name
        enc_type = HtsEncounterType.find_by_name("PRE TEST COUNSELLING").encounter_type_id rescue nil
      elsif $encounter_map["POST TEST COUNSELLING"].include? new_concept_name
        enc_type = HtsEncounterType.find_by_name("POST TEST COUNSELLING").encounter_type_id
      elsif $encounter_map["HTS CLIENT REGISTRATION"].include? new_concept_name
        enc_type = HtsEncounterType.find_by_name("HTS CLIENT REGISTRATION").encounter_type_id
      elsif $encounter_map["HIV TESTING"].include? new_concept_name
        enc_type = HtsEncounterType.find_by_name("HIV TESTING").encounter_type_id
      end

      value_coded = ob['value_coded']
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

      uuid = ActiveRecord::Base.connection.select_one <<EOF
            select uuid()
EOF
      puts "#{enc_id}...#{HtsEncounterType.find_by_encounter_type_id(enc_type).name rescue nil}>>>>>>>>#{ob['obs_id']}...#{concept_id}"

      obs_sql =  "(\"#{obs_id}\",\"#{person_id}\",\"#{concept_id}\",\"#{enc_id}\",\"#{order_id}\",\"#{obs_datetime}\","
      obs_sql += "\"#{location_id}\",\"#{obs_group_id}\",\"#{accession_number}\",\"#{value_group_id}\",\"#{value_boolean}\",\"#{value_coded}\","
      obs_sql += "\"#{value_coded_name_id}\",\"#{value_drug}\",\"#{value_datetime}\",\"#{value_numeric}\",\"#{value_modifier}\",\"#{value_text}\","
      obs_sql += "\"#{}\",\"#{}\",\"#{comments}\",\"#{creator}\",\"#{date_created}\",\"#{voided}\",\"#{voided_by}\",\"#{date_voided}\","
      obs_sql += "\"#{}\",\"#{value_complex}\",\"#{uuid.values.first}\"),"

      `echo -n '#{obs_sql}' >> #{File_destination}/observations.sql`
    end

    encounter_type = HtsEncounterType.find_by_encounter_type_id(enc_type).name rescue nil
    puts "{{{{{{{{{{{{{{#{encounter_type}}}}}}}}}}}}}}}}}}}}"

    enc_sql_statement =  "(\"#{enc_id}\",\"#{enc_type}\",\"#{enc_patient_id}\",\"#{provider_id}\",\"#{enc_location_id}\","
    enc_sql_statement += "\"#{enc_form_id}\",\"#{enc_datetime}\",\"#{enc_creator}\",\"#{enc_date_created}\",\"#{enc_voided}\","
    enc_sql_statement += "\"#{enc_voided_by}\",\"#{enc_date_voided}\",\"#{enc_void_reason}\",\"#{uuid.values.first}\","
    enc_sql_statement += "\"#{enc_changed_by}\",\"#{enc_date_changed}\",\"#{patient_program_id = 1}\"),"

  end

end

start
