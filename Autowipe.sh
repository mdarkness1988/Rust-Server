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
echo "true" >/wipe
chmod +x /apps/wipe-restart_app/app.js
./apps/wipe-restart_app/app.js
fi

sleep 1800
done
