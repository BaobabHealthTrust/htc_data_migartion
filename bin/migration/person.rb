require 'io/console'
Script_started_at = Time.now
File_destination = '/home/pachawo/'


def start

  person_insert_statement = "INSERT INTO person (person_id, gender, birthdate, birthdate_estimated, dead, death_date, "
  person_insert_statement += "cause_of_death, creator, date_created, changed_by, date_changed, voided, voided_by, date_voided, void_reason, uuid) VALUES "

  person_name_insert_statement = "INSERT INTO person_name (person_name_id, preferred, person_id, prefix,  given_name, "
  person_name_insert_statement += "middle_name, family_name_prefix, family_name, family_name2, family_name_suffix, degree, creator, "
  person_name_insert_statement += "date_created, voided, voided_by, date_voided, void_reason, changed_by, date_changed, uuid) VALUES "

  person_address_insert_statement =  "INSERT INTO person_address (person_address_id, person_id, preferred, address1, address2, city_village,"
  person_address_insert_statement += "state_province, postal_code, country, latitude, longitude, creator, date_created, voided,   voided_by, "
  person_address_insert_statement += "date_voided, void_reason, county_district, neighborhood_cell, region, subregion, township_division, uuid) VALUES "

  person_attribute_insert_statement =  "INSERT INTO person_attribute (person_attribute_id,person_id,value,person_attribute_type_id,creator,"
  person_attribute_insert_statement += "date_created,changed_by,date_changed,voided,voided_by,date_voided,void_reason,uuid) VALUES "

  patient_insert_statement = "INSERT INTO patient (patient_id,tribe,creator,date_created,changed_by,date_changed,voided,voided_by,date_voided,void_reason) VALUES "

  patient_program_sql =  "INSERT INTO patient_program (patient_program_id,patient_id,program_id,date_enrolled,date_completed,"
  patient_program_sql += "creator,date_created,changed_by,date_changed,voided,voided_by,date_voided,void_reason,location_id,uuid) VALUES "

  patient_identifier_sql =  "INSERT INTO patient_identifier (patient_identifier_id,patient_id,identifier,identifier_type,preferred,"
  patient_identifier_sql += "location_id,creator,date_created,voided,voided_by,date_voided,void_reason,uuid) VALUES "

  `cd #{File_destination} && [ -f person.sql ] && rm person.sql && [ -f person_name.sql ] && rm person_name.sql && [ -f person_address.sql ] && rm person_address.sql && [ -f person_attribute.sql ] && rm person_attribute.sql && [ -f patient.sql ] && rm patient.sql && [ -f patient_program.sql ] && rm patient_program.sql && [ -f patient_identifier.sql ] && rm patient_identifier.sql`

  `touch person.sql person_name.sql person_address.sql person_attribute.sql patient.sql patient_program.sql patient_identifier.sql`
  `echo -n '#{person_insert_statement}' >> #{File_destination}/person.sql`
  `echo -n '#{person_name_insert_statement}' >> #{File_destination}/person_name.sql`
  `echo -n '#{person_address_insert_statement}' >> #{File_destination}/person_address.sql`
  `echo -n '#{person_attribute_insert_statement}' >> #{File_destination}/person_attribute.sql`
  `echo -n '#{patient_insert_statement}' >> #{File_destination}/patient.sql`
  `echo -n '#{patient_program_sql}' >> #{File_destination}/patient_program.sql`
  `echo -n '#{patient_identifier_sql}' >> #{File_destination}/patient_identifier.sql`

  self.create_person
  self.create_person_name
  self.create_person_address
  self.create_person_attribute
  self.create_patient
  self.create_patient_program
  self.create_patient_identifier
  
  puts "...............please wait............"

  person_sql = File.read("#{File_destination}person.sql")[0...-1]
  File.open("#{File_destination}person.sql", "w") {|sql| sql.puts person_sql << ";"}
  
  person_name_sql = File.read("#{File_destination}person_name.sql")[0...-1]
  File.open("#{File_destination}person_name.sql", "w") {|sql| sql.puts person_name_sql << ";"}

  person_address_sql = File.read("#{File_destination}person_address.sql")[0...-1]
  File.open("#{File_destination}person_address.sql", "w") {|sql| sql.puts person_address_sql << ";"}

  person_attr_sql = File.read("#{File_destination}person_attribute.sql")[0...-1]
  File.open("#{File_destination}person_attribute.sql", "w") {|sql| sql.puts person_attr_sql << ";"}

  patient_sql = File.read("#{File_destination}patient.sql")[0...-1]
  File.open("#{File_destination}patient.sql", "w") {|sql| sql.puts patient_sql << ";"}

  patient_id_sql = File.read("#{File_destination}patient_identifier.sql")[0...-1]
  File.open("#{File_destination}patient_identifier.sql", "w") {|sql| sql.puts patient_id_sql << ";"}

  patient_prog_sql = File.read("#{File_destination}patient_program.sql")[0...-1]
  File.open("#{File_destination}patient_program.sql", "w") {|sql| sql.puts patient_prog_sql << ";"}

  db = YAML::load_file('config/database.yml')
  
  db_user = db['hts']['username']

  source_db = db['hts']['database']

  db_pass = db['hts']['password']


  puts "Loading person...................................."

  `mysql -u '#{db_user}' -p#{db_pass} '#{source_db}' < #{File_destination}person.sql`

  puts "Loading person name..............................."

  `mysql -u '#{db_user}' -p#{db_pass} '#{source_db}' < #{File_destination}person_name.sql`

  puts "Loading person address............................"

  `mysql -u '#{db_user}' -p#{db_pass} '#{source_db}' < #{File_destination}person_address.sql`

  puts "Loading person attributes........................."

  `mysql -u '#{db_user}' -p#{db_pass} '#{source_db}' < #{File_destination}person_attribute.sql`

  puts "Loading patients.................................."

  `mysql -u '#{db_user}' -p#{db_pass} '#{source_db}' < #{File_destination}patient.sql`

  puts "Loading patient identifier........................"

  `mysql -u '#{db_user}' -p#{db_pass} '#{source_db}' < #{File_destination}patient_identifier.sql`
  
  puts "Loading patient programs.........................."

  `mysql -u '#{db_user}' -p#{db_pass} '#{source_db}' < #{File_destination}patient_program.sql`

  puts "Script started at: #{Script_started_at} and ended at #{Time.now}"

end

def self.create_person

  persons = Person.all

  persons.each do |person|

    uuid = ActiveRecord::Base.connection.select_one <<EOF
          select uuid();
EOF

    person_id = person['person_id'].blank? ? 'NULL' : person['person_id']

    person_gender = person['gender'].blank? ? 'NULL' : person['gender']
    
    person_birthdate = person['birthdate'].blank? ? 'NULL' : "\"#{person['birthdate']}\""
    
    person_birthdate_estimated = person['birthdate_estimated'] ? 1 : 0
    
    person_dead = person['dead'] ? 1 : 0
    
    person_death_date = person['death_date'].blank? ? 'NULL' : "\"#{person['death_date']}\""
    
    person_cause_of_death = person['cause_of_death'].blank? ? 'NULL' : "\"#{person['cause_of_death']}\""

    person_date_changed = person['date_changed'].blank? ? 'NULL' : "\"#{person['date_changed']}\""

    person_changed_by = person['changed_by']

    person_creator = person['creator']
    
    person_date_created = person['date_created'].blank? ? 'NULL' : "\"#{person['date_created']}\""

    person_voided_by = person['voided_by']

    person_voided = person['voided'] ? 1 : 0
    
    person_date_voided = person['date_voided'].blank? ? 'NULL' : "\"#{person['date_voided']}\""
    
    person_voided_reason = person['void_reason'].blank? ? 'NULL' : "\"#{person['void_reason']}\""


    if person_gender == "Male" || person_gender == "M"

      person_gender = "M"

    elsif person_gender == "Female" || person_gender == "F"

      person_gender = "F"

    else

      person_gender = "Unknown"

    end

    if !person_creator.blank?

      creator = HtsUser.find_by_user_id(person['creator'])
      
      person_creator = creator.blank? ? 1 : creator.user_id
    
    else
      
      person_creator = 'NULL'
    
    end

    if !person_changed_by.blank?

      changed_by = HtsUser.find_by_user_id(person['changed_by'])
      
      person_changed_by = changed_by.blank? ? 1 : changed_by.user_id
    
    else 
      
      person_changed_by = 'NULL'
    
    end

    if !person_voided_by.blank?

      voided_by = HtsUser.find_by_user_id(person['voided_by'])
      
      person_voided_by = voided_by.blank? ? 1 : voided_by.user_id
    
    else 
      
      person_voided_by = 'NULL'
    
    end

    puts "Writing person >>>>>>>>> #{person['person_id']}"

    person_insert_sql = "(#{person_id},\"#{person_gender}\",#{person_birthdate},#{person_birthdate_estimated},"

    person_insert_sql += "#{person_dead},#{person_death_date},#{person_cause_of_death},#{person_creator},"
    
    person_insert_sql += "#{person_date_created},#{person_changed_by},#{person_date_changed},#{person_voided},"
    
    person_insert_sql += "#{person_voided_by},#{person_date_voided},#{person_voided_reason},\"#{uuid.values.first}\"),"   


    person_exist = HtsPerson.find_by_person_id(person_id)

    if person_exist.blank?

      `echo -n '#{person_insert_sql}' >> #{File_destination}/person.sql`
    
    end

  end

end

def self.create_person_name

  person_names = PersonName.all

  person_names.each do |person_name|
    
    uuid = ActiveRecord::Base.connection.select_one <<EOF
          select uuid();
EOF

    person_name_id = person_name['person_name_id']
    person_name_preferred = person_name['preferred'] ? 1 : 0
    person_name_person_id = person_name['person_id']
    person_name_prefix = person_name['prefix']    
    person_name_gname = person_name['given_name']   
    person_name_mname = person_name ['middle_name']
    person_name_fname_prefix = person_name['family_name_prefix']
    person_name_fname = person_name['family_name']
    person_name_fname2 = person_name['family_name2']
    person_name_fname_suffix = person_name['family_name_suffix']     
    person_name_degree = person_name['degree']
    person_name_creator= person_name['creator']
    person_name_date_created = person_name['date_created']
    person_name_voided = person_name['voided'] ? 1 : 0
    person_name_voided_by = person_name['voided_by']
    person_name_date_voided = person_name['date_voided']
    person_name_void_reason = person_name['void_reason']
    person_name_changed_by = person_name['changed_by']
    person_name_date_changed = person_name['date_changed']
    
    if !person_name_creator.blank?
      creator = HtsUser.find_by_user_id(person_name['creator'])
      person_name_creator = creator.blank? ? 1 : creator.user_id
    else
      person_name_creator = 'null'
    end


    if !person_name_changed_by.blank?
      changed_by = HtsUser.find_by_user_id(person_name['changed_by'])
      person_name_changed_by = changed_by.blank? ? 1 : changed_by.user_id
    else 
      person_name_changed_by = 'null'
    end

    if !person_name_voided_by.blank?
      voided_by = HtsUser.find_by_user_id(person_name['voided_by'])
      person_name_voided_by = voided_by.blank? ? 1 : voided_by.user_id
    else 
      person_name_voided_by = 'null'
    end


    puts "Writing person name ############ #{person_name_id}"

    person_name_insert_sql = "(#{person_name_id},\"#{person_name_preferred}\",\"#{person_name_person_id}\",\"#{person_name_prefix}\",\"#{person_name_gname}\","
    person_name_insert_sql += "\"#{person_name_mname}\",\"#{person_name_fname_prefix}\",\"#{person_name_fname}\",\"#{person_name_fname2}\","
    person_name_insert_sql += "\"#{person_name_fname_suffix}\",\"#{person_name_degree}\",#{person_name_creator},\"#{person_name_date_created}\","
    person_name_insert_sql += "\"#{person_name_voided}\",#{person_name_voided_by},\"#{person_name_date_voided}\", \"#{person_name_void_reason}\","
    person_name_insert_sql += "#{person_name_changed_by},\"#{person_name_date_changed}\",\"#{uuid.values.first}\"),"
    
    person = HtsPersonName.find_by_person_id(person_name_person_id)

    if person.blank?
      `echo -n '#{person_name_insert_sql}' >> #{File_destination}/person_name.sql`
    end

  end

end

def self.create_person_address

  persons_address = PersonAddress.all

  persons_address.each do |person_address|
  
    uuid = ActiveRecord::Base.connection.select_one <<EOF
          select uuid();
EOF
  
    person_address_id = person_address['person_address_id']
    person_address_person_id = person_address['person_id']
    person_address_preferred = person_address['preferred'] ? 1 : 0
    person_address_address1 = person_address['state_province']
    person_address_address2 = person_address['city_village']
    person_address_city_village = person_address['address2']
    person_address_state_province = person_address['address1']
    person_address_postal_code = person_address['postal_code']
    person_address_country = person_address['country']
    person_address_latitude = person_address['latitude']
    person_address_longitude = person_address['longitude']
    person_address_creator = person_address['creator']
    person_address_date_created = person_address['date_created']
    person_address_voided = person_address['voided'] ? 1 : 0
    person_address_voided_by = person_address['voided_by']
    person_address_date_voided = person_address['date_voided']
    person_address_void_reason = person_address['void_reason']
    person_address_county_district = person_address['county_district']
    person_address_neighborhood_cell = person_address['address3']
    person_address_region = person_address['address6']
    person_address_subregion = person_address['address5']
    person_address_township_division = person_address['address4']

    if !person_address_creator.blank?
      creator = HtsUser.find_by_user_id(person_address['creator'])
      person_address_creator = creator.blank? ? 1 : creator.user_id
    else
      person_addess_creator = 'null'
    end

    if !person_address_voided_by.blank?
      voided_by = HtsUser.find_by_user_id(person_address['voided_by'])
      person_address_voided_by = voided_by.blank? ? 1 : voided_by.user_id
    else 
      person_address_voided_by = 'null'
    end

    puts "Writing person address ////////////////// #{person_address_person_id}"

    person_address_insert_sql = "(#{person_address_id},\"#{person_address_person_id}\",\"#{person_address_preferred}\",\"#{person_address_address1}\","
    person_address_insert_sql += "\"#{person_address_address2}\",\"#{person_address_city_village}\",\"#{person_address_state_province}\","
    person_address_insert_sql += "\"#{person_address_postal_code}\",\"#{person_address_country}\",\"#{person_address_latitude}\","
    person_address_insert_sql += "\"#{person_address_longitude}\",#{person_address_creator},\"#{person_address_date_created}\",\"#{person_address_voided}\","
    person_address_insert_sql += "#{person_address_voided_by},\"#{person_address_date_voided}\",\"#{person_address_void_reason}\","
    person_address_insert_sql += "\"#{person_address_county_district}\",\"#{person_address_neighborhood_cell}\",\"#{person_address_region}\","
    person_address_insert_sql += "\"#{person_address_subregion}\",\"#{person_address_township_division}\",\"#{uuid.values.first}\"),"
    
    person_exist = HtsPerson.find_by_person_id(person_address_person_id)
    person_in_address = Person.find_by_person_id(person_address_person_id)
    puts person_in_address.inspect

    if person_exist.blank? && !person_in_address.blank?

        `echo -n '#{person_address_insert_sql}' >> #{File_destination}/person_address.sql`

    end

  end
end

def self.create_person_attribute

  persons_attributes = PersonAttribute.all

  last_hts_person_attr = HtsPersonAttribute.last
  
  if !last_hts_person_attr.blank?
    
    last_hts_attr_id = last_hts_person_attr.person_attribute_id.to_i + 1
  
  else
    
    last_hts_attr_id = 1
  
  end

  persons_attributes.each do |person_attribute|

    uuid = ActiveRecord::Base.connection.select_one <<EOF
          select uuid();
EOF

    person_attribute_id = last_hts_attr_id
    
    person_attribute_person_id = person_attribute['person_id'] 
    
    person_attribute_value = person_attribute['value']
    
    person_attribute_type_id = person_attribute['person_attribute_type_id']
    
    person_attribute_creator = person_attribute['creator']
    
    person_attribute_date_created = person_attribute['date_created']
    
    person_attribute_changed_by = person_attribute['changed_by']
    
    person_attribute_date_changed = person_attribute['date_changed']
    
    person_attribute_voided = person_attribute['voided'] ? 1 : 0
    
    person_attribute_voided_by = person_attribute['voided_by']
    
    person_attribute_date_voided = person_attribute['date_voided']
    
    person_attribute_void_reason = person_attribute['void_reason']

    
    if !person_attribute_creator.blank?
      
      creator = HtsUser.find_by_user_id(person_attribute['creator'])
      
      person_attribute_creator = creator.blank? ? 1 : creator.user_id
    
    else
      
      person_attribute_creator = 'null'
    
    end

    
    if !person_attribute_voided_by.blank?
      
      voided_by = HtsUser.find_by_user_id(person_attribute['voided_by'])
    
      person_attribute_voided_by = voided_by.blank? ? 1 : voided_by.user_id
    
    else 
      
      person_attribute_voided_by = 'null'
    
    end

    
    if !person_attribute_changed_by.blank?
      
      changed_by = HtsUser.find_by_user_id(person_attribute['changed_by'])
      
      person_attribute_changed_by = changed_by.blank? ? 1 : changed_by.user_id
    
    else 
      
      person_attribute_changed_by = 'null'
    
    end

    puts "Writing person attributes  |||||||||||||||||||||| #{person_attribute_id}"

    person_attr_insert_sql = "(#{person_attribute_id},#{person_attribute_person_id},\"#{person_attribute_value}\","
    person_attr_insert_sql += "\"#{person_attribute_type_id}\",#{person_attribute_creator},\"#{person_attribute_date_created}\","
    person_attr_insert_sql += "#{person_attribute_changed_by},\"#{person_attribute_date_changed}\",\"#{person_attribute_voided}\","
    person_attr_insert_sql += "#{person_attribute_voided_by},\"#{person_attribute_date_voided}\",\"#{person_attribute_void_reason}\","
    person_attr_insert_sql += "\"#{uuid.values.first}\"),"

    person_exist = HtsPerson.find_by_person_id(person_attribute_person_id)

    if person_exist.blank?

      `echo -n '#{person_attr_insert_sql}' >> #{File_destination}/person_attribute.sql`
    
    end
    
    last_hts_attr_id = last_hts_attr_id + 1
  
  end

end

def self.create_patient
    patients = Patient.all

    patients.each do |patient|
    
    uuid = ActiveRecord::Base.connection.select_one <<EOF
          select uuid();
EOF

    patient_id = patient['patient_id']
    patient_tribe = patient['tribe'].blank? ? 'null' : patient['tribe']
    patient_creator = patient['creator'] 
    patient_date_created = patient['date_created'] 
    patient_changed_by = patient['changed_by']   
    patient_date_changed = patient['date_changed']   
    patient_voided = patient['voided'] ? 1 : 0
    patient_voided_by = patient['voided_by']  
    patient_date_voided = patient['date_voided']   
    patient_void_reason = patient['void_reason'] 

    if !patient_id.blank?
      person_id = Person.find_by_person_id(patient['patient_id'])
      patient_id = person_id.blank? ? 'null' : person_id.person_id
    else
      patient_id = 'null'
    end

    if !patient_creator.blank?
      creator = HtsUser.find_by_user_id(patient['creator'])
      patient_creator = creator.blank? ? 1 : creator.user_id
    else
      patient_creator = 'null'
    end

    if !patient_voided_by.blank?
      voided_by = HtsUser.find_by_user_id(patient['voided_by'])
      patient_voided_by = voided_by.blank? ? 1 : voided_by.user_id
    else 
      patient_voided_by = 'null'
    end

    if !patient_changed_by.blank?
      changed_by = HtsUser.find_by_user_id(patient['changed_by'])
      patient_changed_by = changed_by.blank? ? 1 : changed_by.user_id
    else 
      patient_changed_by = 'null'
    end

    puts "Writing patient  +++++++++++++++++++++ #{patient_id}"

    patient_insert_sql = "(#{patient_id},#{patient_tribe},#{patient_creator},\"#{patient_date_created}\",#{patient_changed_by},"
    patient_insert_sql += "\"#{patient_date_changed}\",\"#{patient_voided}\",#{patient_voided_by},\"#{patient_date_voided}\",\"#{patient_void_reason}\"),"

    if patient_id != 1 && patient_id != 'null'
      `echo -n '#{patient_insert_sql}' >> #{File_destination}/patient.sql`
    end

    end
end

def self.create_patient_program 
  patients = Patient.all
  
  patient_program_id = 1

  patients.each do |patient|
    patient_id = patient['patient_id']
    date_enrolled = Date.today
    date_completed = ""
    date_created = patient['date_created']
    patient_program_changed_by = patient['changed_by']
    date_changed = ""
    voided = 0
    patient_program_voided_by = ""
    date_voided = ""
    location_id = ""
    void_reason = ""
    program_id = HtsProgram.find_by_name("HTS PROGRAM").program_id
    patient_program_creator = patient['creator']

    if !patient_id.blank?
      person_id = Person.find_by_person_id(patient['patient_id'])
      patient_id = person_id.blank? ? 'null' : person_id.person_id
    else
      patient_id = 'null'
    end

    if !patient_program_creator.blank?
      creator = HtsUser.find_by_user_id(patient['creator'])
      patient_program_creator = creator.blank? ? 1 : creator.user_id
    else
      patient_program_creator = 'null'
    end

    if !patient_program_voided_by.blank?
      voided_by = HtsUser.find_by_user_id(patient['voided_by'])
      patient_program_voided_by = voided_by.blank? ? 1 : voided_by.user_id
    else 
      patient_program_voided_by = 'null'
    end

    if !patient_program_changed_by.blank?
      changed_by = HtsUser.find_by_user_id(patient['changed_by'])
      patient_program_changed_by = changed_by.blank? ? 1 : changed_by.user_id
    else 
      patient_program_changed_by = 'null'
    end
    
    uuid = ActiveRecord::Base.connection.select_one <<EOF
          select uuid();
EOF

    puts "Writing patient program ....................... #{patient_id}"

    program_sql = "(\"#{patient_program_id}\",#{patient_id},#{program_id},\"#{date_enrolled}\",\"#{date_completed}\","
    program_sql += "#{patient_program_creator},\"#{date_created}\",#{patient_program_changed_by},\"#{date_changed}\",\"#{voided}\","
    program_sql += "#{patient_program_voided_by},\"#{date_voided}\",\"#{void_reason}\",\"#{location_id}\",\"#{uuid.values.first}\"),"

    `echo -n '#{program_sql}' >> #{File_destination}/patient_program.sql`

    patient_program_id = patient_program_id + 1

  end

end

def self.create_patient_identifier
  
  patient_identifiers = PatientIdentifier.all

  last_hts_patient_identifier = HtsPatientIdentifier.last

  last_hts_patient_identifier_id = last_hts_patient_identifier.blank? ? 0 : last_hts_patient_identifier.patient_identifier_id rescue nil

  patient_identifiers.each do |patient_identifier|

    patient_identifier_id = last_hts_patient_identifier_id.to_i + 1

    patient_id = patient_identifier['patient_id']

    identifier = patient_identifier['identifier']

    identifier_type = patient_identifier['identifier_type']

    preferred = patient_identifier['preferred'] ? 1 : 0

    identifier_location_id = patient_identifier['location_id']

    identifier_creator = patient_identifier['creator']

    date_created = patient_identifier['date_created']

    voided = patient_identifier['voided'] ? 1 : 0

    identifier_voided_by = patient_identifier['voided_by']

    date_voided = patient_identifier['date_voided']

    void_reason = patient_identifier['void_reason']

    uuid  = ActiveRecord::Base.connection.select_one <<EOF
        select uuid()
EOF


    ########################## check if the patient exist ########################
    if !patient_id.blank?
      patient = Patient.find_by_patient_id(patient_id)
      patient_id = patient.blank? ? 'null' : patient.patient_id
    else 
      patient_id = 'null'
    end

    #############################################################################

    ######################## get HTS identifier type id #########################

    htc_id_type = PatientIdentifierType.find_by_patient_identifier_type_id(identifier_type)
    
    if htc_id_type.name = "HTC Identifier"
      id_type_name = "HTS Number"
      identifier_type = HtsPatientIdentifierType.find_by_name(id_type_name).patient_identifier_type_id
    end
   
    ###########################################################################
    
    if !identifier_creator.blank?
      creator = HtsUser.find_by_user_id(identifier_creator)
      identifier_creator = creator.blank? ? 1 : creator.user_id
    else
      identifier_creator = 1
    end

    if !identifier_voided_by.blank?
      voided_by = HtsUser.find_by_user_id(identifier_voided_by)
      identifier_voided_by = voided_by.blank? ? 1 : voided_by.user_id
    else 
      identifier_voided_by = 'null'
    end

    if !identifier_location_id.blank?
      location = HtsLocation.find_by_location_id(identifier_location_id)
      identifier_location_id = location.blank? ? 1 : location.location_id
    else 
      identifier_location_id = 1
    end

    puts "Writing patient identifier ========================= #{patient_id}"

    sql =   "(#{patient_identifier_id},#{patient_id},\"#{identifier}\",#{identifier_type},#{preferred},#{identifier_location_id},"
    sql +=  "#{identifier_creator},\"#{date_created}\",#{voided},#{identifier_voided_by},\"#{date_voided}\",\"#{void_reason}\",\"#{uuid.values.first}\"),"
    

    `echo -n '#{sql}' >> #{File_destination}/patient_identifier.sql`
  
    last_hts_patient_identifier_id = last_hts_patient_identifier_id.to_i + 1

  end

end

start
