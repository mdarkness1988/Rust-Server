#!/usr/bin/env bash

sleep 900
while :; do

#LOOKS FOR THE MAP FILE
#####################

mapfile="/steamcmd/rust/server/${IDENTITY}"
filename=$(find "${mapfile:?}" -type f -name "proceduralmap.*.map" -print)

#IF SET WIPE DAY IS MET THEN WIPE SERVER
##################################

if [[ $(find "$filename" -mtime +$WIPEDAYS -print) ]]; then
echo "SERVER WIPE IN PROGRESS......."

chmod +x /apps/wipe-restart_app/app.js
node /apps/wipe-restart_app/app.js &

sleep 301

serveridentitydir="/steamcmd/rust/server/${IDENTITY}"
find "${serveridentitydir:?}" -type f -name "proceduralmap.*.sav" -delete
find "${serveridentitydir:?}" -type f -name "proceduralmap.*.map" -delete
find "${serveridentitydir:?}" -type f -name "player.blueprints.*.db" -delete

echo "Server has now been wiped"


fi

sleep 3240
done
