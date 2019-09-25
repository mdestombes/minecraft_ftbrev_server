FROM openjdk:8-jre

# Builder Maintainer
MAINTAINER mdestombes

# Updating container
RUN apt-get update && \
    apt-get install apt-utils --yes && \
    apt-get upgrade --yes --allow-remove-essential && \
    apt-get install -y \
        tmux \
        python && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Configuration variables
ENV SERVER_PORT=25565
ENV DYNMAP_PORT=8123
ENV MOTD="Welcome to Minecraft"
ENV WITH_DYNMAP="NO"
ENV WITH_BUILDCRAFT="NO"
ENV WITH_BLOCKSCAN="NO"
ENV WITH_ENERGY="NO"

# Share the data directory
VOLUME  /minecraft/data

# Setting workdir
WORKDIR /minecraft/downloads

# Changing user to root
USER root

# Creating user
# RUN useradd -m -U minecraft

# Downloading files
RUN wget --no-check-certificate \
        -O /minecraft/downloads/FTBRevelationServer_3.1.0.zip \
        https://media.forgecdn.net/files/2746/968/FTBRevelationServer_3.1.0.zip && \
	unzip FTBRevelationServer_3.1.0.zip && \
	rm FTBRevelationServer_3.1.0.zip && \
	chmod u+x FTBInstall.sh ServerStart.sh

# Running install
RUN /minecraft/downloads/FTBInstall.sh

# Download plugins
WORKDIR /minecraft/downloads/plugins

# List from https://www.curseforge.com/minecraft/mc-mods/dynmapforge/files
RUN wget \
    -O /minecraft/downloads/plugins/Dynmap-3.0-beta-4-forge-1.12.2.jar \
    https://media.forgecdn.net/files/2722/448/Dynmap-3.0-beta-4-forge-1.12.2.jar

# List from https://mod-buildcraft.com/releases/BuildCraft
RUN wget \
    -O /minecraft/downloads/plugins/buildcraft-all-7.99.24.1.jar \
    https://mod-buildcraft.com/releases/BuildCraft/7.99.24.1/buildcraft-all-7.99.24.1.jar

# List from http://mikeprimm.com/dynmap/builds/DynmapBlockScan/
RUN wget \
    -O /minecraft/downloads/plugins/DynmapBlockScan-3.0-beta-1-forge-1.12.2.jar \
    http://mikeprimm.com/dynmap/builds/DynmapBlockScan/DynmapBlockScan-3.0-beta-1-forge-1.12.2.jar

# List from https://www.curseforge.com/minecraft/mc-mods/energy-converters/files
RUN wget \
    -O /minecraft/downloads/plugins/energyconverters-1.12.2-1.3.2.17.jar \
    https://media.forgecdn.net/files/2790/578/energyconverters_1.12.2-1.3.2.17.jar

# Copy runner
WORKDIR /minecraft/bin
COPY run.sh /minecraft/bin/run.sh
COPY configure.py /minecraft/bin/configure.py
COPY dynmap_config.txt /minecraft/bin/dynmap_config.txt
RUN chmod +x /minecraft/bin/run.sh

# Expose needed port
EXPOSE ${SERVER_PORT} ${DYNMAP_PORT}

# Change to the data directory
WORKDIR /minecraft/data

# Change owner
#RUN chown -R minecraft:minecraft /minecraft
#USER minecraft

# Update game launch the game.
ENTRYPOINT ["/minecraft/bin/run.sh"]
