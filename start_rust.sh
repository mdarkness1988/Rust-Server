#!/usr/bin/env bash

# Define the exit handler
exit_handler()
{
	echo "Shutdown signal received"

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
	node /shutdown_app/app.js
	sleep 5
   
if [ "$PPPP" = "1" ]; then
upnp-delete-port "$PORTFORWARD_WEB"
upnp-delete-port "$PORTFORWARD_RUST"
upnp-delete-port "$PORTFORWARD_RCON"
sleep 3
echo ""
echo ""
echo "Port forwarding has closed ports.."
fi

	pkill -f nginx

	#kill -TERM "$child"
   echo ""
	echo "Exiting.."
   sleep 2
   clear
	exit
}

#DEFAULT VARIABLES.
RCONWEB="1"


#CHECHING PERFORMANCE MODE.
if [ "$PERFORMANCE" = "1" ]; then
SECURE="1"
FPS="60"
UPDATEBATCH="128"
AI_TICKRATE="3"
TICKRATE="10"
STARTMODE="0"
SPAWNRATE_MIN="0,1"
SPAWNRATE_MAX="1,5"
SPAWNDENSITY_MIN="0,1"
SPAWNDENSITY_MAX="1,5"
else
if [ "$PERFORMANCE" = "2" ]; then
  SECURE="1"
  FPS="256"
  UPDATEBATCH="256"
  AI_TICKRATE="5"
  TICKRATE="10"
  STARTMODE="0"
  SPAWNRATE_MIN="0,2"
  SPAWNRATE_MAX="2"
  SPAWNDENSITY_MIN="0,2"
  SPAWNDENSITY_MAX="2"
else
if [ "$PERFORMANCE" = "3" ]; then
    SECURE="1"
    FPS="-1"
    UPDATEBATCH="512"
    AI_TICKRATE="7"
    TICKRATE="30"
    STARTMODE="0"
    SPAWNRATE_MIN="0,5"
    SPAWNRATE_MAX="3"
    SPAWNDENSITY_MIN="0,5"
    SPAWNDENSITY_MAX="3"
else
exit
fi
fi
fi

#AUTO MAINTENANCE.
if [ "$AUTO" = "1" ]; then
STARTMODE="0"
OXIDE_UPDATE="1"
else
STARTMODE="0"
OXIDE_UPDATE="0"
fi


if [ "$MAPSIZE" = "tiny" ]; then
MPSIZE="1000”
else
if [ "$MAPSIZE" = "small" ]; then
MPSIZE="2000”
else
if [ "$MAPSIZE" = "medium" ]; then
MPSIZE="3500”
else
if [ "$MAPSIZE" = "large" ]; then
MPSIZE="6000”
else
if [ "$MAPSIZE" = "massive" ]; then
MPSIZE="8000”
else
exit
fi
fi
fi
fi
fi



# Auto port forward ports.

if [ "$PPPP" = "1" ]; then
echo "Port forwarding was enabled"
echo "Starting Port Forwarding....."
upnp-add-port "$PORTFORWARD_WEB"
upnp-add-port "$PORTFORWARD_RUST"
upnp-add-port "$PORTFORWARD_RCON"
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


if [ "$WIPE" = "true" ]; then

serveridentitydir="/steamcmd/rust/server/${RUST_SERVER_IDENTITY}"
find "${serveridentitydir:?}" -type f -name "proceduralmap.*.sav" -delete
find "${serveridentitydir:?}" -type f -name "proceduralmap.*.map" -delete
find "${serveridentitydir:?}" -type f -name "player.blueprints.*.db" -delete

WIPE="false" 
echo "SERVER HAS BEEN WIPED" 
echo ""
echo ""
sleep 5
fi

# Trap specific signals and forward to the exit handler
trap 'exit_handler' SIGHUP SIGINT SIGQUIT SIGTERM

# Remove old locks
rm -fr /tmp/*.lock

# Create the necessary folder structure
if [ ! -d "/steamcmd/rust" ]; then
	echo "Creating folder structure.."
	mkdir -p /steamcmd/rust
fi

# Install/update steamcmd
echo "Installing/updating steamcmd.."
curl -s http://media.steampowered.com/installer/steamcmd_linux.tar.gz | tar -v -C /steamcmd -zx


# Check which branch to use
if [ ! -z ${RUST_BRANCH+x} ]; then
	echo "Using branch arguments: $RUST_BRANCH"
	sed -i "s/app_update 258550.*validate/app_update 258550 $RUST_BRANCH validate/g" /install.txt
else
	sed -i "s/app_update 258550.*validate/app_update 258550 validate/g" /install.txt
fi

# Disable auto-update if start mode is 2
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

# Rust includes a 64-bit version of steamclient.so, so we need to tell the OS where it exists
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/steamcmd/rust/RustDedicated_Data/Plugins/x86_64

# Check if Oxide is enabled
if [ "$OXIDE" = "1" ]; then
	# Next check if Oxide doesn't' exist, or if we want to always update it
	INSTALL_OXIDE="0"
	if [ ! -f "/steamcmd/rust/CSharpCompiler.x86_x64" ]; then
		INSTALL_OXIDE="1"
	fi
	if [ "$OXIDE_UPDATE" = "1" ]; then
		INSTALL_OXIDE="1"
	fi

	# If necessary, download and install latest Oxide
	if [ "$INSTALL_OXIDE" = "1" ]; then
		echo "Downloading and installing latest Oxide.."
		OXIDE_URL=$(curl -s https://api.github.com/repos/OxideMod/Oxide.Rust/releases/latest | grep browser_download_url | cut -d '"' -f 4)
		curl -sL $OXIDE_URL | bsdtar -xvf- -C /steamcmd/rust/
		chmod 755 /steamcmd/rust/CSharpCompiler.x86_x64 2>&1 /dev/null
		
		## NOTE: Disabled until I have time to properly fix this
		#chown -R $PUID:$PGID /steamcmd/rust
	fi
fi

# Start mode 1 means we only want to update
if [ "$STARTMODE" = "1" ]; then
	echo "Exiting, start mode is 1.."
	exit
fi

# Add RCON support if necessary
RUST_STARTUP_COMMAND=$ARGUMENTS
if [ ! -z ${$PORTFORWARD_RCON+x} ]; then
	RUST_STARTUP_COMMAND="$RUST_STARTUP_COMMAND +rcon.port $PORTFORWARD_RCON"
fi
if [ ! -z ${RCONPW+x} ]; then
	RUST_STARTUP_COMMAND="$RUST_STARTUP_COMMAND +rcon.password $RCONPW"
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

# Check if a special seed override file exists
if [ -f "/steamcmd/rust/seed_override" ]; then
	RUST_SEED_OVERRIDE=$(cat /steamcmd/rust/seed_override)
	echo "Found seed override: $RUST_SEED_OVERRIDE"

	# Modify the server identity to include the override seed
	IDENTITY=$RUST_SEED_OVERRIDE
	MAPSEED=$RUST_SEED_OVERRIDE

	# Prepare the identity directory (if it doesn't exist)
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

## Disable logrotate if "-logfile" is set in $RUST_STARTUP_COMMAND
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

	# Set the logfile filename/path
	DATE=$(date '+%Y-%m-%d_%H-%M-%S')
	RUST_SERVER_LOG_FILE="/steamcmd/rust/logs/$IDENTITY"_"$DATE.txt"

	# Archive old logs
	echo "Cleaning up old logs.."
	mv /steamcmd/rust/logs/*.txt /steamcmd/rust/logs/archive
else
	echo "Log rotation disabled!"
fi

# Start cron
echo "Starting scheduled task manager.."
node /scheduler_app/app.js &

# Set the working directory
cd /steamcmd/rust

# Run the server
echo "Starting Rust.."
if [ "$LOGROTATE_ENABLED" = "1" ]; then 
unbuffer /steamcmd/rust/RustDedicated +server.port "$PORTFORWARD_RUST" +server.identity "$IDENTITY" +server.seed "$MAPSEED" +server.hostname "$NAME" +server.url "$WEBURL" +server.headerimage "$BANNER" +server.description "$DESCRIPTION" +server.worldsize "$MPSIZE" +server.maxplayers "$PLAYERS" +fps.limit "$FPS" +server.secure "$SECURE" +server.updatebatch "$UPDATEBATCH" +server.saveinterval "$SAVE_INTERVAL" +server.tickrate "$TICKRATE" +ai.tickrate "$AI_TICKRATE" server.port "$SERVERPORT" +spawn.min_rate "$SPAWNRATE_MIN" +spawn.max_rate "$SPAWNRATE_MAX" +spawn.min_density "$SPAWNDENSITY_MIN" +spawn.max_density "$SPAWNDENSITY_MAX" +server.pve "$PVE" $RUST_STARTUP_COMMAND 2>&1 | grep --line-buffered -Ev '^\s*$|Filename' | tee $RUST_SERVER_LOG_FILE &
else
	/steamcmd/rust/RustDedicated +server.port "$PORTFORWARD_RUST" +server.identity "$IDENTITY" +server.seed "$MAPSEED" +server.hostname "$NAME" +server.url "$WEBURL" +server.headerimage "$BANNER" +server.description "$DESCRIPTION" +server.worldsize "$MPSIZE" +server.maxplayers "$PLAYERS" +fps.limit "$FPS" +server.secure "$SECURE" +server.updatebatch "$UPDATEBATCH" +server.saveinterval "$SAVE_INTERVAL" +server.tickrate "$TICKRATE" +ai.tickrate "$AI_TICKRATE" server.port "$SERVERPORT" +spawn.min_rate "$SPAWNRATE_MIN" +spawn.max_rate "$SPAWNRATE_MAX" +spawn.min_density "$SPAWNDENSITY_MIN" +spawn.max_density "$SPAWNDENSITY_MAX" +server.pve "$PVE" $RUST_STARTUP_COMMAND 2>&1 &
fi

 
if [ "$PPPP" = "1" ]; then
upnp-delete-port "$PORTFORWARD_WEB"
upnp-delete-port "$PORTFORWARD_RUST"
upnp-delete-port "$PORTFORWARD_RCON"
echo ""
echo ""
sleep 3
echo "Port forwarding has closed ports.."
fi

child=$!
wait "$child"
  

pkill -f nginx

echo "Exiting.."
sleep 2
clear
exit
