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
ARGUMENTS (DEFAULT: "")
IDENTITY (DEFAULT: "docker" - Mainly used for the name of the save directory)
SEED (DEFAULT: "0" - The server map seed, must be an integer)
MAP (DEFAULT: "3500" - The map size, must be an integer)
NAME (DEFAULT: "Rust Server" - The publicly visible server name)
RUST_SERVER_MAXPLAYERS (DEFAULT: "200" - Maximum players on the server, must be an integer)
DESCRIPTION (DEFAULT: "This is a Rust server running inside a Docker container!" - The publicly visible server description)
RUST_SERVER_URL (DEFAULT: "https://hub.docker.com/r/mdarkness1988/rust-server/" - The publicly visible server website)
BANNER_URL (DEFAULT: "" - The publicly visible server banner image URL)
INTERVAL (DEFAULT: "300" - Amount of seconds between automatic saves.)
RCON_WEB (DEFAULT "1" - Set to 1 or 0 to enable or disable the web-based RCON server)
RCON_PORT (DEFAULT: "28016" - RCON server port)
PASSWORD (DEFAULT: "server" - RCON server password, please change this!)
RELEASE (DEFAULT: Not set - Sets the branch argument to use, eg. set to "-beta prerelease" for the prerelease branch)
RUST_UPDATE_BRANCH (DEFAULT: "public" - Set to match the branch that you want to use for updating, ie. "prerelease" or "public", but do not specify arguments like "-beta")
OXIDE (DEFAULT: "0" - Set to 1 to automatically install the latest version of Oxide)
SECURE (DEFAULT: "1" - Set to 0 to disable Anti-Hack)
FPS (DEFAULT: "-1" - Limits how many times the server renders objects per second. -1 is no limit)
UPDATEBATCH (DEFAULT: "256” - How fast to update objects in game. More info online <server.updatebatch>)
ANNOUNCE1 (DEFAULT: Empty - Enter announcement messages every so many minutes set by (DELAY). Must fill announce in order from 1-5. Nothing entered will disable announcements)
ANNOUNCE2 (DEFAULT: Blank)
ANNOUNCE3 (DEFAULT: Blank)
ANNOUNCE4 (DEFAULT: Blank)
ANNOUNCE5 (DEFAULT: Blank)
DELAY (DEFAULT: "5" - Enter the amount in minutes to make to the next announcrment)


```

# Logging and rotating logs

The image now supports log rotation, and all you need to do to enable it is to remove any `-logfile` arguments from your startup arguments.
Log files will be created under `logs/` with the server identity and the current date and time.
When the server starts up or restarts, it will move old logs to `logs/archive/`.

# How to send or receive command to/from the server

A small application, called *rcon*, that can both send and receive messages to the server, much like the console on the Windows version, but this happens to use RCON (webrcon).
To use it, simply run the following on the host: `docker exec rust-server rcon say Hello World`, substituting *rust-server* for your own container name

# SUPPORT    [Click Here](https://github.com/mdarkness1988/Rust-Server/issues)

