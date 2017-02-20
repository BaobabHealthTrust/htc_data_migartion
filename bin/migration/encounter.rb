File_destination = '/home/pachawo/'
Script_started_at = Time.now

$location_id = HtsLocation.find_by_name("room 1").location_id

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
    "test 1 lot number" => 'First Pass Test Kit 1 Lot Number',
    "Routine HTC with health service" => 'Routine HTS (PITC) within Health Service',
    "Comes with HTC family Ref slip" => 'Comes with HTS Family Reference Slip',
    "Never Tested" => 'Never Tested',
    "Last Negative" => 'Last Negative',
    "Last Positive" => 'Last Positive',
    "Last Inconclusive" => 'Last Inconclusive',
    "Yes" => 'Yes',
    "No" => 'No',
    "Other" => "Other",
    "Reactive" => 'Reactive',
    "Non-reactive" => 'Non-reactive',
    "Low risk" => 'Low risk',
    "AVD+ or High Risk" => "High risk"
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
  
  `echo -n '#{encounter_sql_statement}' >> #{File_destination}/encounters.sql`

  
  self.create_encounters
  
  self.create_hts_client_registration_encounter

  
  puts "...............please wait............"
  
  obs_sql = File.read("#{File_destination}observations.sql")[0...-1]
  File.open("#{File_destination}observations.sql", "w") {|sql| sql.puts obs_sql << ";"}

  enc_sql = File.read("#{File_destination}encounters.sql")[0...-1]
  File.open("#{File_destination}encounters.sql", "w") {|sql| sql.puts enc_sql << ";"}

  puts "Script started at: #{Script_started_at} and ended at: #{Time.now}"

end

def self.create_encounters

  encounters = Encounter.all

  encounters.each do |encounter|

    enc_id = encounter['encounter_id']
   
    enc_type = encounter['encounter_type']
   
    enc_patient_id = encounter['patient_id']
    
    enc_location_id = $location_id
    
    enc_form_id = encounter['form_id']
    
    enc_datetime = encounter['encounter_datetime']
    
    enc_creator = encounter['creator']
    
    enc_date_created = encounter['date_created']
    
    enc_voided = encounter['voided'] ? 1 : 0
    
    enc_voided_by = encounter['voided_by']
    
    enc_date_voided = encounter['date_voided']
    
    enc_void_reason = encounter['void_reason']
    
    enc_changed_by = encounter['changed_by']
    
    enc_date_changed = encounter['date_changed']
    
    enc_visit_id = encounter['visit_id']
    
    patient_program_id = ''


    if !enc_creator.blank?
      
      creator = HtsUser.find_by_user_id(enc_creator)
      
      enc_creator = creator.blank? ? 1 : creator.user_id
    
    else
      
      enc_creator = 1
    
    end

    
    if !enc_form_id.blank?
      
      form = HtsForm.find_by_form_id(enc_form_id)
      
      enc_form_id = form.blank? ? 'null' : form.form_id
    
    else 
      
      enc_form_id = 'null'
    
    end
    
    
    if !enc_changed_by.blank?
      
      changed_by = HtsUser.find_by_user_id(encounter['changed_by'])
      
      enc_changed_by = changed_by.blank? ? 1 : changed_by.user_id
   
   else 
      
      enc_changed_by = 'null'
    
    end

    
    if !enc_voided_by.blank?
      
      voided_by = HtsUser.find_by_user_id(encounter['voided_by'])
      
      enc_voided_by = voided_by.blank? ? 1 : voided_by.user_id
    
    else 
      
      enc_voided_by = 'null'
    
    end

    
    hts_enc_type_ids = HtsEncounterType.find_by_sql("select * from htc1_7.encounter_type 
      where name in ('HIV TESTING','POST TEST COUNSELLING','HTS CLIENT REGISTRATION','PRE TEST COUNSELLING')")

    hts_enc_type_id_array = []
    
    hts_enc_type_ids.each do |enc_type|
     
      hts_enc_type_id_array << enc_type.encounter_type_id
    
    end

    provider_id = 1

    uuid = ActiveRecord::Base.connection.select_one <<EOF
          select uuid()
EOF

    obs = Observation.find_by_sql("select * from obs where encounter_id = #{enc_id}")

    obs.each do |ob|
      
      obs_id = ob['obs_id']
      
      person_id = ob['person_id']
      
      obs_order_id = ob['order_id']
      
      obs_datetime = ob['obs_datetime']
      
      obs_location_id = $location_id
      
      obs_group_id = ob['obs_group_id'].blank? ? 'null' : ob['obs_group_id']
      
      accession_number = ob['accession_number']
      
      value_group_id = ob['value_group_id'].blank? ? 'null' : ob['value_group_id']
      
      value_boolean = ob['value_boolean']
      
      value_coded_name_id = ob['value_coded_name_id']
      
      value_drug = ob['value_drug'].blank? ? 'null' : ob['value_drug']
      
      value_datetime = ob['value_datetime']
      
      value_numeric = ob['value_numeric']
      
      value_modifier = ob['value_modifier']
      
      value_text = ob['value_text']
      
      value_complex = ob['value_complex']
      
      comments = ob['comments']
      
      obs_creator = ob['creator']
      
      date_created = ob['date_created']
      
      voided = ob['voided'] ? 1 : 0
      
      obs_voided_by = ob['voided_by']
      
      date_voided = ob['date_voided']
      
      value_coded = ob['value_coded']
      
      concept_id = ob['concept_id']

      
      if !value_coded_name_id.blank?
        
        concept_name = HtsConceptName.find_by_concept_name_id(value_coded_name_id)
        
        value_coded_name_id = concept_name.blank? ? 'null' : concept_name.concept_name_id
      
      else
        
        value_coded_name_id = 'null'
      
      end

      
      if !obs_order_id.blank?
        
        order_id = HtsOrder.find_by_order_id(obs_order_id)
        
        obs_order_id = order.blank? ? 'null' : order.order_id
      
      else
        
        obs_order_id = 'null'
      
      end
    
      
      if !obs_creator.blank?
        
        creator = HtsUser.find_by_user_id(obs_creator)
        
        obs_creator = creator.blank? ? 1 : creator.user_id
      
      else
        
        obs_creator = 1
      
      end

      
      if !obs_voided_by.blank?
        
        voided_by = HtsUser.find_by_user_id(obs_voided_by)
        
        obs_voided_by = voided_by.blank? ? 1 : voided_by.user_id
      
      else 
        
        obs_voided_by = 'null'
      
      end


      if !value_coded.blank?
        
        old_value_name = ConceptName.find_by_concept_id(value_coded).name rescue nil
        
        new_value_name = $concept_map[old_value_name]
        
        value_coded = HtsConceptName.find_by_name(new_value_name).concept_id rescue nil

      end

      value_coded = value_coded.blank? ? 'null' : value_coded

      
      if !concept_id.blank?
        
        concept_name = ConceptName.find_by_concept_id(concept_id).name rescue nil
        
        new_concept_name = $concept_map[concept_name]
        
        concept_id = HtsConceptName.find_by_name(new_concept_name).concept_id rescue nil
      
      else
        
        concept_id = 'null'
      
      end

      
      if $encounter_map["PRE TEST COUNSELLING"].include? new_concept_name
        
        enc_type = HtsEncounterType.find_by_name("PRE TEST COUNSELLING").encounter_type_id rescue nil
      
      elsif $encounter_map["POST TEST COUNSELLING"].include? new_concept_name
        
        enc_type = HtsEncounterType.find_by_name("POST TEST COUNSELLING").encounter_type_id
      
      elsif $encounter_map["HTS CLIENT REGISTRATION"].include? new_concept_name
        
        enc_type = HtsEncounterType.find_by_name("HTS CLIENT REGISTRATION").encounter_type_id
      
      elsif $encounter_map["HIV TESTING"].include? new_concept_name
        
        enc_type = HtsEncounterType.find_by_name("HIV TESTING").encounter_type_id
      
      end

      uuid = ActiveRecord::Base.connection.select_one <<EOF
            select uuid()
EOF
      puts "#{enc_id}...#{HtsEncounterType.find_by_encounter_type_id(enc_type).name rescue nil}>>>>>>>>#{ob['obs_id']}...#{concept_id}"

      if !concept_id.blank?

        obs_sql =  "(\"#{obs_id}\",#{person_id},#{concept_id},#{enc_id},#{obs_order_id},\"#{obs_datetime}\","
        
        obs_sql += "#{obs_location_id},#{obs_group_id},\"#{accession_number}\",#{value_group_id},\"#{value_boolean}\",#{value_coded},"
        
        obs_sql += "#{value_coded_name_id},#{value_drug},\"#{value_datetime}\",\"#{value_numeric}\",\"#{value_modifier}\",\"#{value_text}\","
        
        obs_sql += "\"#{}\",\"#{}\",\"#{comments}\",#{obs_creator},\"#{date_created}\",\"#{voided}\",#{obs_voided_by},\"#{date_voided}\","
        
        obs_sql += "\"#{}\",\"#{value_complex}\",\"#{uuid.values.first}\"),"
      
      end

      if hts_enc_type_id_array.include? enc_type
        
        `echo -n '#{obs_sql}' >> #{File_destination}/observations.sql`
      
      end

      patient_program = HtsPatientProgram.find_by_patient_id(person_id)
      
      if !patient_program.blank?
        
        patient_program_id = patient_program.patient_program_id
      
      end


      if !enc_type.blank? 
        
        encounter_type = HtsEncounterType.find_by_encounter_type_id(enc_type)
        
        enc_type = encounter_type.blank? ? 'null' : encounter_type.encounter_type_id
      
      end

    end

    enc_sql_statement =  "(\"#{enc_id}\",\"#{enc_type}\",\"#{enc_patient_id}\",\"#{provider_id}\",#{enc_location_id},"
    
    enc_sql_statement += "#{enc_form_id},\"#{enc_datetime}\",\"#{enc_creator}\",\"#{enc_date_created}\",\"#{enc_voided}\","
    
    enc_sql_statement += "#{enc_voided_by},\"#{enc_date_voided}\",\"#{enc_void_reason}\",\"#{uuid.values.first}\","
    
    enc_sql_statement += "#{enc_changed_by},\"#{enc_date_changed}\",\"#{patient_program_id}\"),"

    
    if hts_enc_type_id_array.include? enc_type
      
      `echo -n '#{enc_sql_statement}' >> #{File_destination}/encounters.sql`
    
    end

  end

end

def self.create_hts_client_registration_encounter
  
  last_htc_encounter = Encounter.last

  last_htc_obs = Observation.last

  last_htc_encounter_id = last_htc_encounter.encounter_id

  encounter_id = last_htc_encounter_id + 1

  last_htc_obs_id = last_htc_obs.obs_id
    
  obs_id = last_htc_obs_id + 1

  patients = Patient.all

  patients.each do |patient|

    obs_order_id = 'null'

    obs_datetime = Observation.find_by_person_id(patient['patient_id']).obs_datetime rescue
    nil

    obs_location_id = $location_id
      
    obs_group_id = 'null'
      
    accession_number = ''
      
    value_group_id = 'null'
      
    value_boolean = 'null'
      
    value_coded_name_id = 'null'
      
    value_drug = 'null'
      
    value_datetime = ''

    value_text = 'null'
      
    value_numeric = 'null'
      
    value_modifier = ''
      
    value_complex = 'null'
      
    comments = ''
     
    obs_creator = '1'
    
    date_created =
    Observation.find_by_person_id(patient['patient_id']).date_created rescue
    nil #Date.today.strftime("%Y-%m-%d 00:00:00")
      
    voided = 0
      
    obs_voided_by = 'null'
      
    date_voided = ''
      
    value_coded = 'null'

    patient_id = patient['patient_id']

    encounter_id = encounter_id

    encounter_type = HtsEncounterType.find_by_name("HTS CLIENT REGISTRATION").encounter_type_id

    enc_form_id = 'null'
    
    enc_void_reason = ''
    
    enc_changed_by = 'null'
    
    enc_date_changed = ''
    
    enc_visit_id = ''
    
    provider = 1

    concepts = $encounter_map['HTS CLIENT REGISTRATION']
          
    person_name = PersonName.find_by_person_id(patient_id)

    concepts.each do |concept|
      
      case concept
        
        when "Sex/Pregnancy"
          
          concept_id = HtsConceptName.find_by_name("Sex/Pregnancy").concept_id

          value_text = "No"

          uuid = ActiveRecord::Base.connection.select_one <<EOF
                select uuid()
EOF
        
          obs_sql =  "(\"#{obs_id}\",#{patient_id},#{concept_id},#{encounter_id},#{obs_order_id},\"#{obs_datetime}\","
          obs_sql += "#{obs_location_id},#{obs_group_id},\"#{accession_number}\",#{value_group_id},\"#{value_boolean}\",#{value_coded},"
          obs_sql += "#{value_coded_name_id},#{value_drug},\"#{value_datetime}\",\"#{value_numeric}\",\"#{value_modifier}\",\"#{value_text}\","
          obs_sql += "\"#{}\",\"#{}\",\"#{comments}\",#{obs_creator},\"#{date_created}\",\"#{voided}\",#{obs_voided_by},\"#{date_voided}\","
          obs_sql += "\"#{}\",\"#{value_complex}\",\"#{uuid.values.first}\"),"

          `echo '#{obs_sql}' >> #{File_destination}/observations.sql`
          
          puts "#{obs_sql}"
          
          obs_id = obs_id + 1

        when "Consent given to be contacted?"      
        
          concept_id = HtsConceptName.find_by_name("Consent given to be contacted?").concept_id

          given_name = person_name.given_name

          family_name = person_name.family_name

          if !given_name.blank? && !family_name.blank?

            value_text = "Yes"

          else

            value_text = "No"

          end

          uuid = ActiveRecord::Base.connection.select_one <<EOF
                select uuid()
EOF
      
          obs_sql =  "(\"#{obs_id}\",#{patient_id},#{concept_id},#{encounter_id},#{obs_order_id},\"#{obs_datetime}\","
          obs_sql += "#{obs_location_id},#{obs_group_id},\"#{accession_number}\",#{value_group_id},\"#{value_boolean}\",#{value_coded},"
          obs_sql += "#{value_coded_name_id},#{value_drug},\"#{value_datetime}\",\"#{value_numeric}\",\"#{value_modifier}\",\"#{value_text}\","
          obs_sql += "\"#{}\",\"#{}\",\"#{comments}\",#{obs_creator},\"#{date_created}\",\"#{voided}\",#{obs_voided_by},\"#{date_voided}\","
          obs_sql += "\"#{}\",\"#{value_complex}\",\"#{uuid.values.first}\"),"

          `echo '#{obs_sql}' >> #{File_destination}/observations.sql`
          
          puts "#{obs_sql}"
          
          obs_id = obs_id + 1    

        when "Contact Detail Type"
          
          concept_id = HtsConceptName.find_by_name("Contact Detail Type").concept_id

          value_text = "Other"

          uuid = ActiveRecord::Base.connection.select_one <<EOF
                select uuid()
EOF
      
          obs_sql =  "(\"#{obs_id}\",#{patient_id},#{concept_id},#{encounter_id},#{obs_order_id},\"#{obs_datetime}\","
          obs_sql += "#{obs_location_id},#{obs_group_id},\"#{accession_number}\",#{value_group_id},\"#{value_boolean}\",#{value_coded},"
          obs_sql += "#{value_coded_name_id},#{value_drug},\"#{value_datetime}\",\"#{value_numeric}\",\"#{value_modifier}\",\"#{value_text}\","
          obs_sql += "\"#{}\",\"#{}\",\"#{comments}\",#{obs_creator},\"#{date_created}\",\"#{voided}\",#{obs_voided_by},\"#{date_voided}\","
          obs_sql += "\"#{}\",\"#{value_complex}\",\"#{uuid.values.first}\"),"
          
          `echo '#{obs_sql}' >> #{File_destination}/observations.sql`

          puts "#{obs_sql}"

          obs_id = obs_id + 1

        when "First name"

          uuid = ActiveRecord::Base.connection.select_one <<EOF
              select uuid()
EOF

          if !person_name.given_name.blank?

            value_text = person_name.given_name

            concept_id = HtsConceptName.find_by_name('First name').concept_id

            obs_sql = "(\"#{obs_id}\",#{patient_id},#{concept_id},#{encounter_id},#{obs_order_id},\"#{obs_datetime}\","
            obs_sql += "#{obs_location_id},#{obs_group_id},\"#{accession_number}\",#{value_group_id},\"#{value_boolean}\",#{value_coded},"
            obs_sql += "#{value_coded_name_id},#{value_drug},\"#{value_datetime}\",\"#{value_numeric}\",\"#{value_modifier}\",\"#{value_text}\","
            obs_sql += "\"#{}\",\"#{}\",\"#{comments}\",#{obs_creator},\"#{date_created}\",\"#{voided}\",#{obs_voided_by},\"#{date_voided}\","
            obs_sql += "\"#{}\",\"#{value_complex}\",\"#{uuid.values.first}\"),"
          
            `echo '#{obs_sql}' >> #{File_destination}/observations.sql`

            puts "#{obs_sql}"
            
            obs_id = obs_id + 1

          end

        when "Last name"
        
          uuid = ActiveRecord::Base.connection.select_one <<EOF
              select uuid()
EOF

          if !person_name.family_name.blank?

            value_text = person_name.family_name

            concept_id = HtsConceptName.find_by_name('Last name').concept_id

            obs_sql = "(\"#{obs_id}\",#{patient_id},#{concept_id},#{encounter_id},#{obs_order_id},\"#{obs_datetime}\","
            obs_sql += "#{obs_location_id},#{obs_group_id},\"#{accession_number}\",#{value_group_id},\"#{value_boolean}\",#{value_coded},"
            obs_sql += "#{value_coded_name_id},#{value_drug},\"#{value_datetime}\",\"#{value_numeric}\",\"#{value_modifier}\",\"#{value_text}\","
            obs_sql += "\"#{}\",\"#{}\",\"#{comments}\",#{obs_creator},\"#{date_created}\",\"#{voided}\",#{obs_voided_by},\"#{date_voided}\","
            obs_sql += "\"#{}\",\"#{value_complex}\",\"#{uuid.values.first}\"),"
            
            `echo '#{obs_sql}' >> #{File_destination}/observations.sql`

            puts "#{obs_sql}"
            
            obs_id = obs_id + 1

          end
          
        when "Age"
        
          person_birthdate = Person.find_by_person_id(patient_id).birthdate

          value_text = (Date.today.year - person_birthdate.to_date.year).to_i

          concept_id = HtsConceptName.find_by_name('Age').concept_id

          uuid = ActiveRecord::Base.connection.select_one <<EOF
                select uuid()
EOF
            
          obs_sql = "(\"#{obs_id}\",#{patient_id},#{concept_id},#{encounter_id},#{obs_order_id},\"#{obs_datetime}\","
          obs_sql += "#{obs_location_id},#{obs_group_id},\"#{accession_number}\",#{value_group_id},\"#{value_boolean}\",#{value_coded},"
          obs_sql += "#{value_coded_name_id},#{value_drug},\"#{value_datetime}\",\"#{value_numeric}\",\"#{value_modifier}\",\"#{value_text}\","
          obs_sql += "\"#{}\",\"#{}\",\"#{comments}\",#{obs_creator},\"#{date_created}\",\"#{voided}\",#{obs_voided_by},\"#{date_voided}\","
          obs_sql += "\"#{}\",\"#{value_complex}\",\"#{uuid.values.first}\"),"
            
          `echo '#{obs_sql}' >> #{File_destination}/observations.sql`

          puts "#{obs_sql}"
            
          obs_id = obs_id + 1
          
        when "Age Group"

          
          obs_id = obs_id + 1    
          puts "#{concept}?????????????#{obs_id}"
          

        when "Year of Birth"
          
          person_birthdate = Person.find_by_person_id(patient_id).birthdate
         
          value_numeric = person_birthdate.to_date.year

          concept_id = HtsConceptName.find_by_name('Year of Birth').concept_id

          uuid = ActiveRecord::Base.connection.select_one <<EOF
                select uuid()
EOF
            
          obs_sql = "(\"#{obs_id}\",#{patient_id},#{concept_id},#{encounter_id},#{obs_order_id},\"#{obs_datetime}\","
          obs_sql += "#{obs_location_id},#{obs_group_id},\"#{accession_number}\",#{value_group_id},\"#{value_boolean}\",#{value_coded},"
          obs_sql += "#{value_coded_name_id},#{value_drug},\"#{value_datetime}\",\"#{value_numeric}\",\"#{value_modifier}\",\"#{value_text}\","
          obs_sql += "\"#{}\",\"#{}\",\"#{comments}\",#{obs_creator},\"#{date_created}\",\"#{voided}\",#{obs_voided_by},\"#{date_voided}\","
          obs_sql += "\"#{}\",\"#{value_complex}\",\"#{uuid.values.first}\"),"
          
          `echo '#{obs_sql}' >> #{File_destination}/observations.sql`

          puts "#{obs_sql}"
            
          obs_id = obs_id + 1
          
      end 

    puts obs_id.inspect

    obs_id = obs_id + 1

    end
    uuid = ActiveRecord::Base.connection.select_one <<EOF
        select uuid()
EOF

    patient_program_id =
    HtsPatientProgram.find_by_patient_id(patient_id).patient_program_id

    encounter_sql = "(\"#{encounter_id}\",\"#{encounter_type}\",\"#{patient_id}\",\"#{provider}\",#{obs_location_id},"
    encounter_sql +=
    "#{enc_form_id},\"#{obs_datetime}\",\"#{obs_creator}\",\"#{date_created}\",\"#{voided}\","
    encounter_sql += "#{obs_voided_by},\"#{date_voided}\",\"#{enc_void_reason}\",\"#{uuid.values.first}\","
    encounter_sql += "#{enc_changed_by},\"#{enc_date_changed}\",\"#{patient_program_id}\"),"


    puts "#{encounter_sql}"
      
    `echo -n '#{encounter_sql}' >> #{File_destination}/encounters.sql`
    
    encounter_id = encounter_id + 1

  end



  #Year of BirthAge GroupAgeLast nameFirst nameContact Detail TypeConsent given to be contacted?Sex/Pregnancy

end

start
#create_hts_client_registration_encounter
