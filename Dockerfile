FROM didstopia/base:nodejs-steamcmd-ubuntu-16.04

MAINTAINER Mdarkness1988 <>

# Fix apt-get warnings
ARG DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    nginx \
    expect \
    tcl \
    python-miniupnpc \
    libgdiplus && \
    rm -rf /var/lib/apt/lists/*

# Remove default nginx stuff
RUN rm -fr /usr/share/nginx/html/* && \
	rm -fr /etc/nginx/sites-available/* && \
	rm -fr /etc/nginx/sites-enabled/*

# COPY upnp to correct location
COPY UPNP/upnp-add-port /usr/bin/upnp-add-port
RUN chmod +x /usr/bin/upnp-add-port
COPY UPNP/upnp-delete-port /usr/bin/upnp-delete-port
RUN chmod +x /usr/bin/upnp-delete-port

COPY wipe /wipe

# COPY Autowipe.sh file
COPY Autowipe.sh /Autowipe.sh
RUN chmod +x /Autowipe.sh


# COPY title.sh file
COPY title.sh /title.sh
RUN chmod +x /title.sh


# Install webrcon (specific commit)
COPY nginx_rcon.conf /etc/nginx/nginx.conf
RUN curl -sL https://github.com/Facepunch/webrcon/archive/24b0898d86706723d52bb4db8559d90f7c9e069b.zip | bsdtar -xvf- -C /tmp && \
	mv /tmp/webrcon-24b0898d86706723d52bb4db8559d90f7c9e069b/* /usr/share/nginx/html/ && \
	rm -fr /tmp/webrcon-24b0898d86706723d52bb4db8559d90f7c9e069b

# Customize the webrcon package to fit our needs
ADD fix_conn.sh /tmp/fix_conn.sh
RUN chmod +x /tmp/fix_conn.sh

# Create and set the steamcmd folder as a volume
RUN mkdir -p /steamcmd/rust
VOLUME ["/steamcmd/rust"]

# Setup proper shutdown support
ADD apps/shutdown_app/ /apps/shutdown_app/
WORKDIR /apps/shutdown_app
RUN chmod -R 777 /apps/shutdown_app
RUN npm install

# Setup restart support (for update automation)
ADD apps/restart_app/ /apps/restart_app/
WORKDIR /apps/restart_app
RUN chmod -R 777 /apps/restart_app
RUN npm install

# Setup restart support (for wipe restart)
ADD apps/wipe-restart_app/ /apps/wipe-restart_app/
WORKDIR /apps/wipe-restart_app
RUN chmod -R 777 /apps/wipe-restart_app
RUN npm install

# Setup announce (for auto announcements)
ADD apps/announce_app/ /apps/announce_app/
WORKDIR /apps/announce_app
RUN chmod -R 777 /apps/announce_app
RUN npm install

# Setup wiped date title
ADD apps/title_app/ /apps/title_app/
WORKDIR /apps/title_app
RUN chmod -R 777 /apps/title_app
RUN npm install

# Setup scheduling support
ADD apps/scheduler_app/ /apps/scheduler_app/
WORKDIR /apps/scheduler_app
RUN chmod -R 777 /apps/scheduler_app
RUN npm install

# Setup rcon command relay app
ADD apps/rcon_app/ /apps/rcon_app/
WORKDIR /apps/rcon_app
RUN chmod -R 777 /apps/rcon_app
RUN npm install
RUN ln -s /apps/rcon_app/app.js /usr/bin/rcon

# Add the steamcmd installation script
ADD install.txt /install.txt

# Copy the Rust startup script
ADD start_rust.sh /start.sh
RUN chmod +x /start.sh

# Copy the Rust update check script
ADD update_check.sh /update_check.sh
RUN chmod +x /update_check.sh

# Copy extra files
COPY README.md LICENSE.md /

# Set the current working directory
WORKDIR /

# Expose necessary ports
EXPOSE 8080/TCP
EXPOSE 28015/TCP
EXPOSE 28015/UDP
EXPOSE 28016/TCP

# Setup default environment variables for the server
ENV NAME ""
ENV DESCRIPTION ""
ENV PUBLIC ""
ENV AUTO ""
ENV OXIDE ""
ENV RELEASE ""
ENV PASSWORD ""
ENV BANNER ""
ENV PLAYERS ""
ENV MAPSIZE ""
ENV PERFORMANCE ""
ENV IDENTITY ""
ENV PORTFORWARD_RUST ""
ENV PORTFORWARD_WEB ""
ENV PORTFORWARD_RCON ""
ENV PVE ""
ENV MAPSEED ""
ENV SAVE_INTERVAL ""

# Rcon used variables
ENV WIPEDAYS ""
ENV WIPE_TITLE ""
ENV WIPED_TITLE ""

ENV ANNOUNCE_DELAY ""
ENV ANNOUNCE1 ""
ENV ANNOUNCE2 ""
ENV ANNOUNCE3 ""
ENV ANNOUNCE4 ""
ENV ANNOUNCE5 ""

# Not used in docker template
ENV WIPED ""

# Start the server
ENTRYPOINT ["./start.sh"]
