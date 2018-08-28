#!/usr/bin/env bash

# Define the exit handler
exit_handler()
{
	echo "Shutdown signal received"

if [ "$PUBLIC" = "1" ]; then
upnp-delete-port "$PORTFORWARD_WEB"
upnp-delete-port "$PORTFORWARD_RUST"
upnp-delete-port "$RUST_RCON_PORT"
sleep 3
echo ""
echo ""
echo "Port forwarding has closed ports.."
fi

	# Only do backups if we're using the seed override
	if [ -f "/steamcmd/rust/seed_override" ]; then
		# Create the backup directory if it doesn't exist
		if [ ! -d "/steamcmd/rust/bak" ]; then
			mkdir -p /steamcmd/rust/bak
		fi
		if [ -f "/steamcmd/rust/server/$IDENTITY/UserPersistence.db" ]; then
			# Backup all the current unlocked blueprint data
			cp -fr "/steamcmd/rust/server/$IDENTITY/UserPersistence*.db" "/steamcmd/rust/bak/"
		fi

		if [ -f "/steamcmd/rust/server/$IDENTITY/xp.db" ]; then
			# Backup all the current XP data
			cp -fr "/steamcmd/rust/server/$IDENTITY/xp*.db" "/steamcmd/rust/bak/"
		fi
	fi
	
	# Execute the RCON shutdown command
	node /apps/shutdown_app/app.js
	sleep 5

	pkill -f nginx

	#kill -TERM "$child"
   echo ""
	echo "Exiting.."
	exit
}

################################################
# Trap specific signals and forward to the exit handler
trap 'exit_handler' SIGHUP SIGINT SIGQUIT SIGTERM
################################################




#DEFAULT VARIABLES.
#################

RCONWEB="1"


#CHECHING PERFORMANCE MODE.
##########################

if [ "$PERFORMANCE" = "1" ]; then
SECURE="True"
FPS="70"
UPDATEBATCH="128"
AI_TICKRATE="3"
TICKRATE="10"
STARTMODE="0"
     elif [ "$PERFORMANCE" = "2" ]; then
     SECURE="True"
     FPS="256"
     UPDATEBATCH="256"
     AI_TICKRATE="5"
     TICKRATE="10"
     STARTMODE="0"
          elif [ "$PERFORMANCE" = "3" ]; then
          SECURE="True"
          FPS="-1"
          UPDATEBATCH="512"
          AI_TICKRATE="6"
          TICKRATE="30"
          STARTMODE="0"
     else
  echo "Error: Please select performance"
fi

# PVP SETTINGS
#############

if [ "$PVE" = "0" ]; then
echo "PVP Mode"
PVE_="False"
else
echo "PVE Mode"
PVE_="True"
fi

# AUTO MAINTENANCE.
##################

if [ "$AUTO" = "1" ]; then
STARTMODE="0"
OXIDE_UPDATE="1"
else
STARTMODE="0"
OXIDE_UPDATE="0"
fi



#SELECT MAP SIZE
###############

if [ "$MAPSIZE" = "tiny" ]; then
MPSIZE="1000"
elif [ "$MAPSIZE" = "small" ]; then
MPSIZE="2000"
elif [ "$MAPSIZE" = "medium" ]; then
MPSIZE="3500"
elif [ "$MAPSIZE" = "large" ]; then
MPSIZE="6000"
elif [ "$MAPSIZE" = "massive" ]; then
MPSIZE="8000"
else
echo "Error: Please select map size"
fi



# AUTO PORT FORWARDING
#####################

if [ "$PUBLIC" = "1" ]; then
echo "Port forwarding was enabled"
echo "Starting Port Forwarding....."
upnp-add-port "$PORTFORWARD_WEB"
upnp-add-port "$PORTFORWARD_RUST"
upnp-add-port "$RUST_RCON_PORT"
sleep 3
echo "Port forwarding has opened ports"
sleep 2
echo ""
echo ""
else
echo "Port forwarding is disabled in settings"
echo ""
echo ""
sleep 3
fi


#RUN AUTO WIPE
##############

if [ -z "$WIPEDAYS" ]; then
echo "Auto wipe not set"
else
echo "Auto wipe has been set to wipe every $WIPEDAYS days"
echo ""
echo ""
chmod +x Autowipe.sh
./Autowipe.sh &
fi



#RUN WIPE TITLE
##############

if [ "$WIPE_TITLE" = "1" ]; then

   mapfile="/steamcmd/rust/server/${IDENTITY}"
   filename=$(find "${mapfile:?}" -type f -name "proceduralmap.*.map" -print)
   filedate=$(date -r $filename +'%d/%m')
   WIPED_TITLE=":  Wiped $filedate"
   export WIPED_TITLE
   chmod +x apps/title_app/app.js
   ./apps/title_app/app.js &
fi



#RUN ANNOUNCEMENTS
###################

ANNOUNCE="0"

if [ -z "$ANNOUNCE1" ]; then
  if [ -z "$ANNOUNCE2" ]; then
    if [ -z "$ANNOUNCE3" ]; then
      if [ -z "$ANNOUNCE4" ]; then
        if [ -z "$ANNOUNCE5" ]; then
        echo "Announce not set"
        else
        ANNOUNCE="1"
        fi
      else
      ANNOUNCE="1"
      fi
    else
    ANNOUNCE="1"
    fi
  else
  ANNOUNCE="1"
  fi
else
ANNOUNCE="1"
fi


if [ "$ANNOUNCE" = "1" ]; then
chmod +x apps/announce_app/app.js
./apps/announce_app/app.js &
fi



# REMOVE OLD LOCK
################

rm -fr /tmp/*.lock


# CREATE THE NECESSARY FOLDER STRUCTURE
####################################

if [ ! -d "/steamcmd/rust" ]; then
	echo "Creating folder structure.."
	mkdir -p /steamcmd/rust
fi



# INSTALL/UPDATE STEAMCMD
########################

echo "Installing/updating steamcmd.."
curl -s http://media.steampowered.com/installer/steamcmd_linux.tar.gz | tar -v -C /steamcmd -zx


# CHECK WHICH BRANCH TO USE
#########################

if [ ! -z ${RUST_BRANCH+x} ]; then
	echo "Using branch arguments: $RUST_BRANCH"
	sed -i "s/app_update 258550.*validate/app_update 258550 $RUST_BRANCH validate/g" /install.txt
else
	sed -i "s/app_update 258550.*validate/app_update 258550 validate/g" /install.txt
fi


#DISABLE AUTO-UPDATE IF START MODE IS 2
##################################

if [ "$STARTMODE" = "2" ]; then
	# Check that Rust exists in the first place
	if [ ! -f "/steamcmd/rust/RustDedicated" ]; then
		# Install Rust from install.txt
		echo "Installing Rust.. (this might take a while, be patient)"
		bash /steamcmd/steamcmd.sh +runscript /install.txt
		#STEAMCMD_OUTPUT=$(bash /steamcmd/steamcmd.sh +runscript /install.txt | tee /dev/stdout)
		#STEAMCMD_ERROR=$(echo $STEAMCMD_OUTPUT | grep -q 'Error')
		#if [ ! -z "$STEAMCMD_ERROR" ]; then
		#	echo "Exiting, steamcmd install or update failed: $STEAMCMD_ERROR"
		#	exit
		#fi
	else
		echo "Rust seems to be installed, skipping automatic update.."
	fi
else
	# Install/update Rust from install.txt
	echo "Installing/updating Rust.. (this might take a while, be patient)"
	bash /steamcmd/steamcmd.sh +runscript /install.txt
	#STEAMCMD_OUTPUT=$(bash /steamcmd/steamcmd.sh +runscript /install.txt | tee /dev/stdout)
	#STEAMCMD_ERROR=$(echo $STEAMCMD_OUTPUT | grep -q 'Error')
	#if [ ! -z "$STEAMCMD_ERROR" ]; then
	#	echo "Exiting, steamcmd install or update failed: $STEAMCMD_ERROR"
	#	exit
	#fi

	# Run the update check if it's not been run before
	if [ ! -f "/steamcmd/rust/build.id" ]; then
		./update_check.sh
	else
		OLD_BUILDID="$(cat /steamcmd/rust/build.id)"
		STRING_SIZE=${#OLD_BUILDID}
		if [ "$STRING_SIZE" -lt "6" ]; then
			./update_check.sh
		fi
	fi
fi




# TELL OS WERE 64-BIT VERSION OF STEAMCLIENT.SO IS
################################################

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/steamcmd/rust/RustDedicated_Data/Plugins/x86_64



#CHECK IF OXIDE IS ENABLED
######################

if [ "$OXIDE" = "1" ]; then
	# Next check if Oxide doesn't' exist, or if we want to always update it
	INSTALL_OXIDE="0"

  if [ ! -f "/steamcmd/rust/Compiler.x86_x64" ]; then
    if [ ! -f "/steamcmd/rust/CSharpCompiler.x86_x64" ]; then
		  INSTALL_OXIDE="1"
	 fi
  fi

	if [ "$OXIDE_UPDATE" = "1" ]; then
		INSTALL_OXIDE="1"
	fi

	# If necessary, download and install latest Oxide
	if [ "$INSTALL_OXIDE" = "1" ]; then
		echo "Downloading and installing latest Oxide.."
		OXIDE_URL=$(curl -s https://api.github.com/repos/OxideMod/Oxide.Rust/releases/latest | grep browser_download_url | cut -d '"' -f 4)
		curl -sL $OXIDE_URL | bsdtar -xvf- -C /steamcmd/rust/

	if [ -f "/steamcmd/rust/Compiler.x86_x64" ]; then
		chmod +x /steamcmd/rust/Compiler.x86_x64 2>&1 /dev/null
  elif [ -f "/steamcmd/rust/CSharpCompiler.x86_x64" ]; then
     chmod +x /steamcmd/rust/CSharpCompiler.x86_x64 2>&1 /dev/null
	fi
		
		## NOTE: Disabled until I have time to properly fix this
		chmod -R 777 /steamcmd/rust
	fi
fi



# START MODE 1: ONLY UPDATES
#########################

if [ "$STARTMODE" = "1" ]; then
	echo "Exiting, start mode is 1.."
	exit
fi



# ADD RCON SUPPORT IF NECESSARY
############################

RUST_STARTUP_COMMAND=$ARGUMENTS
if [ ! -z ${RUST_RCON_PORT+x} ]; then
	RUST_STARTUP_COMMAND="$RUST_STARTUP_COMMAND +rcon.port $RUST_RCON_PORT"
fi
if [ ! -z ${RUST_RCON_PASSWORD+x} ]; then
	RUST_STARTUP_COMMAND="$RUST_STARTUP_COMMAND +rcon.password $RUST_RCON_PASSWORD"
fi

if [ ! -z ${RCONWEB+x} ]; then
	RUST_STARTUP_COMMAND="$RUST_STARTUP_COMMAND +rcon.web $RCONWEB"
	if [ "$RCONWEB" = "1" ]; then
		# Fix the webrcon (customizes a few elements)
		bash /tmp/fix_conn.sh

		# Start nginx (in the background)
		echo "Starting web server.."
		nginx
		NGINX=$!
		sleep 5
		#nginx -g "daemon off;" && sleep 5 ## Used for debugging nginx
	fi
fi



# CHECK IF A SPECIAL SEED OVERRIDE FILE EXISTS
######################################

if [ -f "/steamcmd/rust/seed_override" ]; then
	RUST_SEED_OVERRIDE=$(cat /steamcmd/rust/seed_override)
	echo "Found seed override: $RUST_SEED_OVERRIDE"

	# Modify the server identity to include the override seed
	IDENTITY=$RUST_SEED_OVERRIDE
	MAPSEED=$RUST_SEED_OVERRIDE



  # PREPARE THE IDENTITY DIRECTORY (IF NOT EXIST)

	if [ ! -d "/steamcmd/rust/server/$RUST_SEED_OVERRIDE" ]; then
		echo "Creating seed override identity directory.."
		mkdir -p "/steamcmd/rust/server/$RUST_SEED_OVERRIDE"
		if [ -f "/steamcmd/rust/UserPersistence.db.bak" ]; then
			echo "Copying blueprint backup in place.."
			cp -fr "/steamcmd/rust/UserPersistence.db.bak" "/steamcmd/rust/server/$RUST_SEED_OVERRIDE/UserPersistence.db"
		fi
		if [ -f "/steamcmd/rust/xp.db.bak" ]; then
			echo "Copying blueprint backup in place.."
			cp -fr "/steamcmd/rust/xp.db.bak" "/steamcmd/rust/server/$RUST_SEED_OVERRIDE/xp.db"
		fi
	fi
fi



## DISABLE LOGROTATE IF "-LOGFILE" IS SET IN $RUST_STARTUP_COMMAND
#########################################################

LOGROTATE_ENABLED=1
RUST_STARTUP_COMMAND_LOWERCASE=$(echo "$RUST_STARTUP_COMMAND" | sed 's/./\L&/g')
if [[ $RUST_STARTUP_COMMAND_LOWERCASE == *" -logfile "* ]]; then
	LOGROTATE_ENABLED=0
fi

if [ "$LOGROTATE_ENABLED" = "1" ]; then
	echo "Log rotation enabled!"

	# Log to stdout by default
	echo "Using startup arguments: $ARGUMENTS"

	# Create the logging directory structure
	if [ ! -d "/steamcmd/rust/logs/archive" ]; then
		mkdir -p /steamcmd/rust/logs/archive
	fi

	# SET THE LOGFILE FILENAME/PATH

	DATE=$(date '+%Y-%m-%d_%H-%M-%S')
	RUST_SERVER_LOG_FILE="/steamcmd/rust/logs/$IDENTITY"_"$DATE.txt"

	# ARCHIVE OLD LOGS

	echo "Cleaning up old logs.."
	mv /steamcmd/rust/logs/*.txt /steamcmd/rust/logs/archive
else
	echo "Log rotation disabled!"
fi



# START CRON
###########

echo "Starting scheduled task manager.."
node /apps/scheduler_app/app.js &



# SET THE WORKING DIRECTORY
########################

cd /steamcmd/rust



# RUN THE SERVER
###############

echo "Starting Rust.."
if [ "$LOGROTATE_ENABLED" = "1" ]; then 
unbuffer /steamcmd/rust/RustDedicated -batchmode -load +server.port "$PORTFORWARD_RUST" +server.identity "$IDENTITY" +server.seed "$MAPSEED" +server.hostname "$NAME" +server.url "$WEBURL" +server.headerimage "$BANNER" +server.description "$DESCRIPTION" +server.worldsize "$MPSIZE" +server.maxplayers "$PLAYERS" +fps.limit "$FPS" +server.secure "$SECURE" +server.updatebatch "$UPDATEBATCH" +server.saveinterval "$SAVE_INTERVAL" +server.tickrate "$TICKRATE" +ai.tickrate "$AI_TICKRATE" server.port "$SERVERPORT" +server.pve "$PVE_" $RUST_STARTUP_COMMAND 2>&1 | grep --line-buffered -Ev '^\s*$|Filename' | tee $RUST_SERVER_LOG_FILE &
else
	/steamcmd/rust/RustDedicated -batchmode -load +server.port "$PORTFORWARD_RUST" +server.identity "$IDENTITY" +server.seed "$MAPSEED" +server.hostname "$NAME" +server.url "$WEBURL" +server.headerimage "$BANNER" +server.description "$DESCRIPTION" +server.worldsize "$MPSIZE" +server.maxplayers "$PLAYERS" +fps.limit "$FPS" +server.secure "$SECURE" +server.updatebatch "$UPDATEBATCH" +server.saveinterval "$SAVE_INTERVAL" +server.tickrate "$TICKRATE" +ai.tickrate "$AI_TICKRATE" server.port "$SERVERPORT" +server.pve "$PVE_" $RUST_STARTUP_COMMAND 2>&1 &
fi



child=$!
wait "$child"

if [ "$PUBLIC" = "1" ]; then
upnp-delete-port "$PORTFORWARD_WEB"
upnp-delete-port "$PORTFORWARD_RUST"
upnp-delete-port "$RUST_RCON_PORT"
sleep 3
echo ""
echo ""
echo "Port forwarding has closed ports.."
fi
  

pkill -f nginx

echo "Exiting.."
sleep 2
exit
