#!/usr/bin/env bash

sleep 2
while :; do

mapfile="/steamcmd/rust/server/${IDENTITY}"
filename=$(find "${mapfile:?}" -type f -name "proceduralmap.*.map" -print)

if [[ $(find "$filename" -mtime +"$WIPEDAYS" -print) ]]; then
echo "SERVER WIPE IN PROGRESS"

node /wipe-restart_app/app.js
sleep 1
wait

serveridentitydir="/steamcmd/rust/server/${IDENTITY}"
find "${serveridentitydir:?}" -type f -name "proceduralmap.*.sav" -delete
find "${serveridentitydir:?}" -type f -name "proceduralmap.*.map" -delete
find "${serveridentitydir:?}" -type f -name "player.blueprints.*.db" -delete
fi

sleep 3240
done