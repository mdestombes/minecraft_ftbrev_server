#!/usr/bin/env bash

echo "************************************************************************"
echo "* Minecraft Server launching... ("`date`")"
echo "************************************************************************"
java -version

# Trap management
[[ -p /tmp/FIFO ]] && rm /tmp/FIFO
mkfifo /tmp/FIFO
export TERM=linux

# Stop management
function stop {

  echo -e "\n*************************************************"
  echo "* Send stop to Minecraft server"
  echo "*************************************************"

  # Stoping minecraft server
  tmux send-keys -t minecraft "stop" C-m

  echo -e "\n*************************************************"
  echo "* Minecraft server stopping"
  echo "*************************************************"

  sleep 10

  echo -e "\n*************************************************"
  echo "* Minecraft server stoppped"
  echo "*************************************************"

  exit
}

# Init dynmap configuration
function init_dynmap {

  if [[ ${FIRST_LAUNCH} -eq 1 ]]; then
    echo -e "\n*************************************************"
    echo "* Specific configuration of Minecraft server..."
    echo "*************************************************"
    echo "Waiting for first intialization..."
    sleep 180

    while [[ `cat /minecraft/data/logs/latest.log | grep '\[Dynmap\]: \[Dynmap\] Enabled'` == "" ]]; do
      echo "...Waiting more..."
      sleep 10
    done

    echo "Stopping Minecraft server..."
    # Stoping minecraft server
    tmux send-keys -t minecraft "stop" C-m

    sleep 60

    echo "Upgrade Dynmap config..."
    cat /minecraft/bin/dynmap_config.txt | sed \
        -e "s:__MOTD__:${MOTD}:g" \
        -e "s:__DYNMAP_PORT__:${DYNMAP_PORT}:g" \
        > /minecraft/data/dynmap/configuration.txt

    echo "Restarting Minecraft server..."

    # Launching minecraft server
    tmux send-keys -t minecraft "/minecraft/data/ServerStart.sh" C-m

  fi
}

# Install
if [[ ! -f /minecraft/data/ServerStart.sh ]]; then

  # Copy install
  cp -fr /minecraft/downloads/* /minecraft/data

  # Move plugins
  mv /minecraft/data/plugins/* /minecraft/data/mods
  rm -fr /minecraft/data/plugins

  # Init plugins needed
  FIRST_LAUNCH=1

else

  # Init plugins needed
  FIRT_LAUNCH=0

fi

# Eula License
if [[ ! -f /minecraft/data/eula.txt ]]; then

  # Check Minecraft license
  if [[ "$EULA" != "" ]]; then
    echo "# Generated via Docker on $(date)" > /minecraft/data/eula.txt
    echo "eula=$EULA" >> /minecraft/data/eula.txt
  else
    echo ""
    echo "Please accept the Minecraft EULA at"
    echo "  https://account.mojang.com/documents/minecraft_eula"
    echo "by adding the following immediately after 'docker run':"
    echo "  -e EULA=TRUE"
    echo "or editing eula.txt to 'eula=true' in your server's data directory."
    echo ""
    exit 1
  fi
fi

# Check server configuration
[[ ! -f /minecraft/data/server.properties ]] || [[ "${FORCE_CONFIG}" = "true" ]] && python /minecraft/bin/configure.py --config

# Minecraft server session creation
tmux new -s minecraft -c /minecraft/data -d

# Launching minecraft server
tmux send-keys -t minecraft "PATH=$PATH" C-m
tmux send-keys -t minecraft "/minecraft/data/ServerStart.sh" C-m

# Stop server in case of signal INT or TERM
trap stop INT
trap stop TERM
read < /tmp/FIFO &

# Dynmap port configuration
init_dynmap

echo -e "\n*************************************************"
echo "* Minecraft server launched. Wait few minutes..."
echo "*************************************************"
wait
