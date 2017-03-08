# README

## HTC - HTS Data Migration Script

* Ruby version
  
  ruby 2.3.1p112 or higher

* System dependencies

  gem version 2.5.1

  rails version 5.0.1 or higher

* Configuration

  1. Clone the application to your working directory 
      (i.e git clone https://github.com/BaobabHealthTrust/htc_data_migartion.git)

  2. Copy and rename all .example files by removing .example 
      (i.e cp config/database.yml.example config/database.yml)

  3. Configure your database.yml file (located in config folder) by
      providing username and password for your database. For database under htc_module, 
      provide database name for HTC application, hts database under hts and hts_inventory
      database under hts_inventory.

* Database creation

  1. Run **rake:db create**

* How to run the migration

  1. Using your favourite editor open  person.rb located in bin/migration.
      Edit variable **File_destination** by providing path to which you want your
      sql files reside after running the scripts. (e.g **File_destination = '/home/pachawo/'**)
      and save.

  2. Do the same step i with the encounter.rb and inventory.rb located in the same folder, bin/migration.

  3. In you command line run, **rails runner bin/migration/person.rb**
      (Used to transform and save data from HTC to hts)

  4. Again run, **rails runner bin/migration/encounter.rb**
      (Used to transform and save data from HTC to hts).

  5. To migrate inventory data run, **rails runner bin/migration/inventory.rb**
      (..............Work still in progress......)

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
