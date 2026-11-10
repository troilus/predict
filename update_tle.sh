#!/bin/bash

echo -e "- Updating TLEs...\n";
curl -k -o ./satellite_data/satonline.txt https://www.amsat.org/tle/dailytle.txt;

cat ./satellite_data/meteorsats.txt >> ./satellite_data/satonline.txt;

sed -i 's/ASRTU-1 (RS64S\/BJ2CR)/ASRTU-1 (RS64S\/BJ2CR\/AO-123)/g' ./satellite_data/satonline.txt;

echo -e "\n- Updating transmitter data...\n";
curl -o ./satellite_data/transmitters.json "https://db.satnogs.org/api/transmitters/?format=json&status=active";

echo "\n- Done.";
