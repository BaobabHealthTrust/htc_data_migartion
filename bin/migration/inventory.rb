File_destination = '/home/pachawo'

def start

	stock_inserts  = "INSERT INTO stock (stock_id, name, description, in_multiples_of, reorder_level," 
	stock_inserts += "last_order_size, recommended_test_time, window_test_time, voided,void_reason, date_voided," 
	stock_inserts += "voided_by, category_id, date_created, creator, date_changed, changed_by) VALUES"

	receipt_inserts  = "INSERT INTO receipt (receipt_id, stock_id, batch_number, expiry_date, origin_facility, receipt_quantity,"
	receipt_inserts += "receipt_datetime, receipt_who_received, date_created, creator, date_changed changed_by, voided,"
	receipt_inserts += "void_reason, date_voided, voided_by) VALUES"

	dispatch_inserts  = "INSERT INTO receipt (dispatch_id, stock_id, batch_number, dispatch_quantity, dispatch_datetime,"
	dispatch_inserts += "dispatch_who_dispatched, dispatch_who_received, dispatch_who_authorised, dispatch_destination,"
	dispatch_inserts += "date_created, creator,	date_changed, changed_by, voided, void_reason,	date_voided voided_by,) VALUES"

	`cd #{File_destination} && touch stock.sql receipt.sql dispatch.sql`
	`echo -n '#{stock_inserts}' >> #{File_destination}/stock.sql`
	`echo -n '#{receipt_inserts}' >> #{File_destination}/receipt.sql`
	`echo -n '#{dispatch_inserts}' >> #{File_destination}/dispatch.sql`


	
	self.create_stock
	self.create_receipts
	#self.create_dispatch
end

def self.create_stock

  kits = Kits.all

  kits.each do |kit|

    kit_id = kit['id']

    kit_name = kit['name'].blank? ? "NULL" : "\"#{kit['name']}\""

    kit_desc = kit['description'].blank? ? "NULL" : "\"#{kit['description']}\""

    kit_duration = kit['duration'].blank? ? "NULL" : "\"#{kit['duration']}\""
    
    inventories = Inventory.find_by_sql("select * from inventory where kit_type = #{kit_id}")

    inventories.each do |inventory|

      inventory_type = inventory['inventory_type']

      inventory_type_name = InventoryType.find_by_id(inventory_type).name rescue nil
		
      inventory_id = inventory['id']

      lot_number = inventory['lot_no']
 
      value_text = inventory['value_text']

      value_date = inventory['value_date']

      date_of_expiry = inventory['date_of_expiry']

      encounter_date = inventory['encounter_date']

      comments = inventory["comments"]

      location_id = $location_id

      creator = inventory["creator"]

      voided = inventory["voided"] ? 1 : 0

      void_reason = inventory["void_reason"].blank? ? "NULL" : "\"#{inventory["void_reason"]}\""

      date_created = inventory["created_at"].blank? ? "NULL" : "\"#{inventory["created_at"]}\""
      
      date_updated = inventory["updated_at"].blank? ? "NULL" : "\"#{inventory["updated_at"]}\""

      in_multiples_of = 'NULL'
		
      reorder_level = "NULL"
		
      last_order_size = inventory['value_numeric'].blank? ? 'NULL' : "\"#{inventory['value_numeric']}\""
		
      window_test_time  = "NULL"
		
      void_reason = "NULL"
		
      date_voided = "NULL"
		
      voided_by = "NULL"
		
      category_id = "NULL"
		
		  changed_by ="NULL"

      case inventory_type_name

        when "Delivery"

          puts "Creating stocks...................."
          #>>>>>>>>>>>>> creating stocks <<<<<<<<<<<<<<<<<#
          
		      stock_insert_sql  = "(#{inventory_id},#{kit_name},#{kit_desc},#{in_multiples_of},#{reorder_level},"
		      
          stock_insert_sql += "#{last_order_size},#{kit_duration},#{window_test_time},#{voided},"
		      
          stock_insert_sql += "#{void_reason},#{date_voided},#{voided_by},#{category_id},#{date_created},"
		      
          stock_insert_sql += "#{creator},#{date_updated},\"#{changed_by}\"),"

          `echo -n '#{stock_insert_sql}' >> #{File_destination}/stock.sql`

      end

    end

  end

  stock_sql = File.read("#{File_destination}/stock.sql")[0...-1]
  File.open("#{File_destination}/stock.sql", "w") {|sql| sql.puts stock_sql << ";"}

  puts "Database username: "

  db_user = $stdin.gets.chomp

  puts "Destination database name: "

  source_db = $stdin.gets.chomp
  
  puts "Database password: "

  db_pass = $stdin.gets.chomp


  `mysql -u '#{db_user}' -p#{db_pass} '#{source_db}' < #{File_destination}/stock.sql`

end

def self.create_receipts

	inventories = Inventory.all

	inventories.each do |inventory|

		receipt_id = ""

		stock_id = inventory['kit_type']

		batch_number = inventory['lot_number']

		expiry_date = inventory['date_of_expiry']

		origin_facility = "null"

		receipt_quantity = inventory['value_numeric']

		receipt_datetime = inventory['value_datetime']

		receipt_who_received = inventory['creator']

		date_created = inventory['created_at']

		creator = inventory['creator']

		date_changed = ""

		changed_by = "null"

		voided = "0"

		void_reason = ""

		date_voided = ""

		voided_by = ""

		receipt_insert_sql  = "(#{receipt_id},\"#{stock_id}\",\"#{batch_number}\",\"#{expiry_date}\",\"#{origin_facility}\","
		receipt_insert_sql += "\"#{receipt_quantity}\",\"#{receipt_datetime}\",\"#{receipt_who_received}\",\"#{date_created}\","
		receipt_insert_sql += "\"#{creator}\",\"#{date_changed}\",\"#{changed_by}\",\"#{voided}\",\"#{void_reason}\","
		receipt_insert_sql += "\"#{date_voided}\",\"#{voided_by}\"),"

		`echo -n '#{receipt_insert_sql}' >> #{File_destination}/receipt.sql`

		puts "populating receipt table  <><><><> #{stock_id}"

	end

end

def self.create_dispatch

	councillor_inventories = Councillor_inventory.all

	councillor_inventories.each do |councillor_inventory|

		dispatch_id = councillor_inventory['id']

		stock_id = ""

		batch_number = councillor_inventory['lot_no']

		dispatch_quantity = councillor_inventory['value_numeric']

		dispatch_datetime = councillor_inventory['encounter_datetime']

		dispatch_who_dispatched = councillor_inventory['creator']

		dispatch_who_received = ""

		dispatch_who_authorised = ""

		dispatch_destination = councillor_inventory['location_id']

		date_created = councillor_inventory['created_at']

		creator = councillor_inventory['creator']

		date_changed = councillor_inventory['updated_at']

		changed_by = ""

		voided = "0"

		void_reason =""

		date_voided = ""

		voided_by = ""


		councillor_inventory_insert_sql = "(#{dispatch_id},\"#{stock_id}\",\"#{batch_number}\",\"#{dispatch_quantity}\","
		councillor_inventory_insert_sql += "\"#{dispatch_datetime}\",\"#{dispatch_who_dispatched}\",\"#{dispatch_who_received}\","
		councillor_inventory_insert_sql += "\"#{dispatch_who_authorised}\",\"#{dispatch_destination}\",\"#{date_created}\","
		councillor_inventory_insert_sql += "\"#{creator}\",\"#{date_changed}\",\"#{changed_by}\",\"#{voided}\",\"#{void_reason}\",\"#{date_voided}\",\"voided_by}\"),"
	
		`echo -n '#{councillor_inventory_insert_sql}' >> #{File_destination}/dispatch.sql`

		puts "populating councillor_inventory table  ////////////////////// #{batch_number}"

	end
end
#self.create_stock
start
