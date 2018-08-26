#!/usr/bin/env bash

sleep 900
while :; do

#LOOKS FOR THE MAP FILE
#####################

mapfile="/steamcmd/rust/server/${IDENTITY}"
filename=$(find "${mapfile:?}" -type f -name "proceduralmap.*.map" -print)

echo "$filename  TEST"

#IF SET WIPE DAY IS MET THEN WIPE SERVER
##################################

if [[ $(find "$filename" -mtime +"$WIPEDAYS" -print) ]]; then
echo "SERVER WIPE IN PROGRESS"

node /wipe-restart_app/app.js &
WIPED="true"

fi

sleep 3240
done
