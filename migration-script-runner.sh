#!/usr/bin/env sh



echo "Initiating the scripts to run ...";



echo "Checking the Person script ...";

 [ -f bin/migration/person.rb ]  &&  echo "Running the Person script..."   &&  rails runner bin/migration/person.rb &&  echo "script executed successfully..."  || echo "file not found...";

echo "Checking the first encounters script...";


[ -f bin/migration/encounter.rb ]  &&  echo "Running the Ecounters script..."  &&  rails runner bin/migration/encounter.rb  &&  echo "script executed successfully..."  || echo "file not found...";  


echo "Checking the second encounters script...";


[ -f bin/migration/encounters.rb ]  &&  echo "Running the second Ecounters script..."  &&  rails runner bin/migration/encounters.rb  &&  echo "script executed successfully..."  || echo "file not found...";
  

echo "Checking the Inventory script...";


[ -f bin/migration/inventory.rb ]  &&  echo "Running the Inventory script..." && rails runner bin/migration/inventory.rb  &&  echo "script executed successfully..."  || echo "file not found...";


echo "#######################################################";

echo "Done!";

