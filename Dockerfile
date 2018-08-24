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
COPY upnp-add-port /usr/bin/upnp-add-port
RUN chmod +x /usr/bin/upnp-add-port
COPY upnp-delete-port /usr/bin/upnp-delete-port
RUN chmod +x /usr/bin/upnp-delete-port


# Install webrcon (specific commit)
COPY nginx_rcon.conf /etc/nginx/nginx.conf
RUN curl -sL https://github.com/Facepunch/webrcon/archive/24b0898d86706723d52bb4db8559d90f7c9e069b.zip | bsdtar -xvf- -C /tmp && \
	mv /tmp/webrcon-24b0898d86706723d52bb4db8559d90f7c9e069b/* /usr/share/nginx/html/ && \
	rm -fr /tmp/webrcon-24b0898d86706723d52bb4db8559d90f7c9e069b

# Customize the webrcon package to fit our needs
ADD fix_conn.sh /tmp/fix_conn.sh

# Create and set the steamcmd folder as a volume
RUN mkdir -p /steamcmd/rust
VOLUME ["/steamcmd/rust"]

# Setup proper shutdown support
ADD shutdown_app/ /shutdown_app/
WORKDIR /shutdown_app
RUN npm install

# Setup restart support (for update automation)
ADD restart_app/ /restart_app/
WORKDIR /restart_app
RUN npm install

# Setup scheduling support
ADD scheduler_app/ /scheduler_app/
WORKDIR /scheduler_app
RUN npm install

# Setup rcon command relay app
ADD rcon_app/ /rcon_app/
WORKDIR /rcon_app
RUN npm install
RUN ln -s /rcon_app/app.js /usr/bin/rcon

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
ENV RUST_RCON_PASSWORD ""
ENV BANNER ""
ENV PLAYERS ""
ENV MAPSIZE ""
ENV PERFORMANCE ""
ENV IDENTITY ""
ENV PORTFORWARD_RCON ""
ENV PORTFORWARD_WEB ""
ENV RUST_RCON_PORT ""
ENV PVE ""
ENV MAPSEED ""
ENV SAVE_INTERVAL ""

ENV WIPE "false"

# Start the server
ENTRYPOINT ["./start.sh"]
