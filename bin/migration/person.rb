File_destination = '~/'
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
  person_attribute_insert_statement += "date_created,changed_by,date_changed,voided,voided_by,date_voided,void_reason,uui) VALUES "

  patient_insert_statement = "INSERT INTO patient (patient_id,tribe,creator,date_created,changed_by,date_changed,voided,voided_by,date_voided,void_reason) VALUES "

  patient_program_sql =  "INSERT INTO patient_program (patient_program_id,patient_id,program_id,date_enrolled,date_completed,"
  patient_program_sql += "creator,date_created,changed_by,date_changed,voided,voided_by,date_voided,void_reason,location_id,uuid) VALUES "


  `cd #{File_destination} && touch person.sql person_name.sql person_address.sql person_attribute.sql patient.sql patient_program.sql`
  `echo -n '#{person_insert_statement}' >> #{File_destination}/person.sql`
  `echo -n '#{person_name_insert_statement}' >> #{File_destination}/person_name.sql`
  `echo -n '#{person_address_insert_statement}' >> #{File_destination}/person_address.sql`
  `echo -n '#{person_attribute_insert_statement}' >> #{File_destination}/person_attribute.sql`
  `echo -n '#{patient_insert_statement}' >> #{File_destination}/patient.sql`
  `echo -n '#{patient_program_sql}' >> #{File_destination}/patient_program.sql`

  self.create_person
  self.create_person_name
  self.create_person_address
  self.create_person_attribute
  self.create_patient
  self.create_patient_program

end

def self.create_person

  persons = Person.all

  persons.each do |person|

    uuid = ActiveRecord::Base.connection.select_one <<EOF
          select uuid();
EOF

    person_id = person['person_id'].blank? ? 'null' : person['person_id']
    person_gender = person['gender'].blank? ? 'null' : person['gender']
    person_birthdate = person['birthdate'].blank? ? 'null' : person['birthdate']
    person_birthdate_estimated = person['birthdate_estimated'] ? 1 : 0
    person_dead = person['dead'] ? 1 : 0
    person_death_date = person['death_date'].blank? ? 'null' : person['death_date']
    person_cause_of_death = person['cause_of_death'].blank? ? 'null' : person['cause_of_death']
    person_creator = person['creator'].blank? ? 'null' : person['creator']
    person_date_created = person['date_created'].blank? ? 'null' : person['date_created']
    person_changed_by = person['changed_by'].blank? ? 'null' : person['changed_by']
    person_date_changed = person['date_changed'].blank? ? 'null' : person['date_changed']
    person_voided = person['voided'] ? 1 : 0
    person_voided_by = person['voided_by'].blank? ? 'null' : person['voided_by']
    person_date_voided = person['date_voided'].blank? ? 'null' : person['date_voided']
    person_voided_reason = person['void_reason'].blank? ? 'null' : person['void_reason']

    puts "Writing person >>>>>>>>> #{person['person_id']}"

    person_insert_sql = "(#{person_id},\"#{person_gender}\",\"#{person_birthdate}\",\"#{person_birthdate_estimated}\","
    person_insert_sql += "\"#{person_dead}\",\"#{person_death_date}\",\"#{person_cause_of_death}\",\"#{person_creator}\","
    person_insert_sql += "\"#{person_date_created}\",\"#{person_changed_by}\",\"#{person_date_changed}\",\"#{person_voided}\","
    person_insert_sql += "\"#{person_voided_by}\",\"#{person_date_voided}\",\"#{person_voided_reason}\",\"#{uuid.values.first}\"),"   

    `echo -n '#{person_insert_sql}' >> #{File_destination}/person.sql`
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

    puts "Writing person name ############ #{person_name_id}"

    person_name_insert_sql = "(#{person_name_id},\"#{person_name_preferred}\",\"#{person_name_person_id}\",\"#{person_name_prefix}\",\"#{person_name_gname}\","
    person_name_insert_sql += "\"#{person_name_mname}\",\"#{person_name_fname_prefix}\",\"#{person_name_fname}\",\"#{person_name_fname2}\","
    person_name_insert_sql += "\"#{person_name_fname_suffix}\",\"#{person_name_degree}\",\"#{person_name_creator}\",\"#{person_name_date_created}\","
    person_name_insert_sql += "\"#{person_name_voided}\",\"#{person_name_voided_by}\",\"#{person_name_date_voided}\", \"#{person_name_void_reason}\","
    person_name_insert_sql += "\"#{person_name_changed_by}\",\"#{person_name_date_changed}\",\"#{uuid.values.first}\"),"

    `echo -n '#{person_name_insert_sql}' >> #{File_destination}/person_name.sql`

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
    person_address_address1 = person_address['address1']
    person_address_address2 = person_address['address2']
    person_address_city_village = person_address['city_village']
    person_address_state_province = person_address['state_province']
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

    puts "Writing person address ////////////////// #{person_address_id}"

    person_address_insert_sql = "(#{person_address_id},\"#{person_address_person_id}\",\"#{person_address_preferred}\",\"#{person_address_address1}\","
    person_address_insert_sql += "\"#{person_address_address2}\",\"#{person_address_city_village}\",\"#{person_address_state_province}\","
    person_address_insert_sql += "\"#{person_address_postal_code}\",\"#{person_address_country}\",\"#{person_address_latitude}\","
    person_address_insert_sql += "\"#{person_address_longitude}\",\"#{person_address_creator}\",\"#{person_address_date_created}\",\"#{person_address_voided}\","
    person_address_insert_sql += "\"#{person_address_voided_by}\",\"#{person_address_date_voided}\",\"#{person_address_void_reason}\","
    person_address_insert_sql += "\"#{person_address_county_district}\",\"#{person_address_neighborhood_cell}\",\"#{person_address_region}\","
    person_address_insert_sql += "\"#{person_address_subregion}\",\"#{person_address_township_division}\",\"#{uuid.values.first}\"),"

    `echo -n '#{person_address_insert_sql}' >> #{File_destination}/person_address.sql`

  end
end

def self.create_person_attribute

  persons_attributes = PersonAttribute.all

  persons_attributes.each do |person_attribute|

    uuid = ActiveRecord::Base.connection.select_one <<EOF
          select uuid();
EOF

    person_attribute_id = person_attribute['person_attribute_id']
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

    puts "Writing person attributes  |||||||||||||||||||||| #{person_attribute_id}"

    person_attr_insert_sql = "(\"#{person_attribute_id}\",\"#{person_attribute_person_id}\",\"#{person_attribute_value}\","
    person_attr_insert_sql += "\"#{person_attribute_type_id}\",\"#{person_attribute_creator}\",\"#{person_attribute_date_created}\","
    person_attr_insert_sql += "\"#{person_attribute_changed_by}\",\"#{person_attribute_date_changed}\",\"#{person_attribute_voided}\","
    person_attr_insert_sql += "\"#{person_attribute_voided_by}\",\"#{person_attribute_date_voided}\",\"#{person_attribute_void_reason}\",\"#{uuid.values.first}\"),"

    `echo -n '#{person_attr_insert_sql}' >> #{File_destination}/person_attribute.sql`

  end
end

def self.create_patient
    patients = Patient.all

    patients.each do |patient|
    
    uuid = ActiveRecord::Base.connection.select_one <<EOF
          select uuid();
EOF

    patient_id = patient['patient_id']
    patient_tribe = patient ['tribe'] 
    patient_creator = patient['creator'] 
    patient_date_created = patient['date_created'] 
    patient_changed_by = patient['changed_by']   
    patient_date_changed = patient['date_changed']   
    patient_voided = patient['voided'] ? 1 : 0
    patient_voided_by = patient['voided_by']  
    patient_date_voided = patient['date_voided']   
    patient_void_reason = patient['void_reason'] 

    puts "Writing patient  +++++++++++++++++++++ #{patient_id}"

    patient_insert_sql = "(\"#{patient_id}\",\"#{patient_tribe}\",\"#{patient_creator}\",\"#{patient_date_created}\",\"#{patient_changed_by}\","
    patient_insert_sql += "\"#{patient_date_changed}\",\"#{patient_voided}\",\"#{patient_voided_by}\",\"#{patient_date_voided}\",\"#{patient_void_reason}\"),"

    `echo -n '#{patient_insert_sql}' >> #{File_destination}/patient.sql`
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
    changed_by = ""
    date_changed = ""
    voided = 0
    voided_by = ""
    date_voided = ""
    location_id = ""
    void_reason = ""
    program_id = HtsProgram.find_by_name("HTS PROGRAM").program_id
    creator = patient['creator']
    
    uuid = ActiveRecord::Base.connection.select_one <<EOF
          select uuid();
EOF

    puts "Writing patient program ....................... #{patient_id}"

    program_sql = "(\"#{patient_program_id}\",\"#{patient_id}\",\"#{program_id}\",\"#{date_enrolled}\",\"#{date_completed}\","
    program_sql += "\"#{creator}\",\"#{date_created}\",\"#{changed_by}\",\"#{date_changed}\",\"#{voided}\",\"#{voided_by}\","
    program_sql += "\"#{date_voided}\",\"#{void_reason}\",\"#{location_id}\",\"#{uuid.values.first}\"),"

    `echo -n '#{program_sql}' >> #{File_destination}/patient_program.sql`

    patient_program_id = patient_program_id + 1

  end

end
start
