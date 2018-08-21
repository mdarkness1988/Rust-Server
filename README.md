# Rust server that runs inside a Docker container

---

**DISCLAIMER:**
```
Cracked or pirated versions of Rust are not supported in any way, shape or form. Please do not post issues regarding these.
```

---

[![Install on DigitalOcean](http://installer.71m.us/button.svg)](http://installer.71m.us/install?url=https://github.com/mdarkness1988/rust-server)

**FEATURES**

       1. Automatic updates on release (Default: Enabled in config)
       2. Auto Wipe on server updates
       3. Login with Stean username and password if required
       4. UPnP support for auto port forwarding when running server (Default: Enabled in config)
       5. MORE YET TO COME



# TUTORIAL:
**If you want to manually install this container you can by these simple steps**

1. Add new container under Docker tab.
2. Give the container a name you prefer.
3. Add ``` mdarkness1988/rust-server ``` in Repository.
4. Add the variables you want from the list below.
5. Add ports to container, (8080/TCP, 28015/TCP&UDP, 28016/TCP).
6. Save Template and RUN :)

**NOTE**: This image will install/update on startup. The path ```/steamcmd/rust``` can be mounted on the host for data persistence.  
Also note that this image provides the new web-based RCON, so you should set ```RUST_RCON_PASSWORD``` to a more secure password.
This image also supports having a modded server (using Oxide), check the ```RUST_OXIDE_ENABLED``` variable below.


The following environment variables are available if you wish to modify the template:
```
RUST_SERVER_STARTUP_ARGUMENTS (DEFAULT: "")
RUST_SERVER_IDENTITY (DEFAULT: "docker" - Mainly used for the name of the save directory)
RUST_SERVER_SEED (DEFAULT: "0" - The server map seed, must be an integer)
RUST_SERVER_WORLDSIZE (DEFAULT: "3500" - The map size, must be an integer)
RUST_SERVER_NAME (DEFAULT: "Rust Server [DOCKER]" - The publicly visible server name)
RUST_SERVER_MAXPLAYERS (DEFAULT: "200" - Maximum players on the server, must be an integer)
RUST_SERVER_DESCRIPTION (DEFAULT: "This is a Rust server running inside a Docker container!" - The publicly visible server description)
RUST_SERVER_URL (DEFAULT: "https://hub.docker.com/r/mdarkness1988/rust-server/" - The publicly visible server website)
RUST_SERVER_BANNER_URL (DEFAULT: "" - The publicly visible server banner image URL)
RUST_SERVER_SAVE_INTERVAL (DEFAULT: "300" - Amount of seconds between automatic saves.)
RUST_RCON_WEB (DEFAULT "1" - Set to 1 or 0 to enable or disable the web-based RCON server)
RUST_RCON_PORT (DEFAULT: "28016" - RCON server port)
RUST_RCON_PASSWORD (DEFAULT: "docker" - RCON server password, please change this!)
RUST_BRANCH (DEFAULT: Not set - Sets the branch argument to use, eg. set to "-beta prerelease" for the prerelease branch)
RUST_UPDATE_CHECKING (DEFAULT: "1" - Set to 1 to enable fully automatic update checking, notifying players and restarting to install updates)
RUST_UPDATE_BRANCH (DEFAULT: "public" - Set to match the branch that you want to use for updating, ie. "prerelease" or "public", but do not specify arguments like "-beta")
RUST_START_MODE (DEFAULT: "0" - Determines if the server should update and then start (0), only update (1) or only start (2))
RUST_OXIDE_ENABLED (DEFAULT: "0" - Set to 1 to automatically install the latest version of Oxide)
RUST_OXIDE_UPDATE_ON_BOOT (DEFAULT: "1" - Set to 0 to disable automatic update of Oxide on boot)
RUST_SERVER_SECURE (DEFAULT: "1" - Set to 0 to disable Anti-Hack)
RUST_SERVER_FPS (DEFAULT: "-1" - Limits how many times the server renders objects per second. -1 is no limit)
RUST_SERVER_UPDATEBATCH (DEFAULT: "256” - How fast to update objects in game. More info online <server.updatebatch>)
STEAMUSER (DEFAULT: "BLANK" - Keep it empty for anonymous login else enter your steam username (CAP Sensitive))
STEAMPW (DEFAULT: "BLANK" - Enter your steam password (CAP Sensitive) if you have entered username into STEAMUSER)
UPNP (DEFAULT: "1" - Enable or disable the option for the server to open your ports automaticly if you wish to access the server outside your network)

```

# Logging and rotating logs

The image now supports log rotation, and all you need to do to enable it is to remove any `-logfile` arguments from your startup arguments.
Log files will be created under `logs/` with the server identity and the current date and time.
When the server starts up or restarts, it will move old logs to `logs/archive/`.

# How to send or receive command to/from the server

A small application, called *rcon*, that can both send and receive messages to the server, much like the console on the Windows version, but this happens to use RCON (webrcon).
To use it, simply run the following on the host: `docker exec rust-server rcon say Hello World`, substituting *rust-server* for your own container name

# SUPPORT    [Click Here](https://github.com/mdarkness1988/Rust-Server/issues)

