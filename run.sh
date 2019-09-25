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

# Init mods
function init_mods {

  if [[ ! -f /minecraft/data/mods_initialized ]]; then
    echo -e "\n*************************************************"
    echo "* Mods installation..."
    echo "*************************************************"

    if [[ "${WITH_DYNMAP}" == "YES" ]]; then
      echo "Add DynMap mod..."
      # Copy plugins
      cp -f /minecraft/data/plugins/Dynmap-* /minecraft/data/mods
    else
      echo "Avoiding DynMap mod!"
    fi

    if [[ "${WITH_BUILDCRAFT}" == "YES" ]]; then
      echo "Add Buildcraft mod..."
      # Copy plugins
      cp -f /minecraft/data/plugins/buildcraft-all-* /minecraft/data/mods
    else
      echo "Avoiding Buildcraft mod!"
    fi

    if [[ "${WITH_BLOCKSCAN}" == "YES" ]]; then
      echo "Add DynMap Blockscan mod..."
      # Copy plugins
      cp -f /minecraft/data/plugins/DynmapBlockScan-* /minecraft/data/mods
    else
      echo "Avoiding DynMap Blockscan mod!"
    fi

    if [[ "${WITH_ENERGY}" == "YES" ]]; then
      echo "Add Energy mod..."
      # Copy plugins
      cp -f /minecraft/data/plugins/energyconverters-* /minecraft/data/mods
    else
      echo "Avoiding Energy mod!"
    fi

    touch /minecraft/data/mods_initialized

  fi
}

# Check mods launched
function check_mods {

  echo -e "\n*************************************************"
  echo "* Mods management..."
  echo "*************************************************"

  sleep 10

  if [[ "${WITH_DYNMAP}" == "YES" ]]; then
    if [[ `cat /minecraft/data/logs/latest.log | grep 'Unable to read the jar file Dynmap-'` == "" ]]; then
      echo "DynMap mod launched..."

      # Dynmap port configuration
      init_dynmap
    else
      echo "DynMap mod launch failed..."
    fi
  fi

  if [[ "${WITH_BUILDCRAFT}" == "YES" ]]; then
    if [[ `cat /minecraft/data/logs/latest.log | grep 'Unable to read the jar file buildcraft-all-'` == "" ]]; then
      echo "Buildcraft mod launched..."
    else
      echo "Buildcraft mod launch failed..."
    fi
  fi

  if [[ "${WITH_BLOCKSCAN}" == "YES" ]]; then
    if [[ `cat /minecraft/data/logs/latest.log | grep 'Unable to read the jar file DynmapBlockScan-'` == "" ]]; then
      echo "DynMap Blockscan mod launched..."
    else
      echo "DynMap Blockscan mod launch failed..."
    fi
  fi

  if [[ "${WITH_ENERGY}" == "YES" ]]; then
    if [[ `cat /minecraft/data/logs/latest.log | grep 'Unable to read the jar file energyconverters-'` == "" ]]; then
      echo "Energy mod launched..."
    else
      echo "Energy mod launch failed..."
    fi
  fi

}

# Init dynmap configuration
function init_dynmap {

  if [[ ! -f /minecraft/data/dynmap_initialized ]] && [[ "${WITH_DYNMAP}" == "YES" ]]; then
    echo -e "\n*************************************************"
    echo "* Specific configuration of Dynmap..."
    echo "*************************************************"
    echo "Waiting for first intialization..."
    if [[ "${WITH_BLOCKSCAN}" == "YES" ]]; then
      sleep 180
    else
      sleep 60
    fi

    while [[ `cat /minecraft/data/logs/latest.log | grep '\[Dynmap\]: \[Dynmap\] Enabled'` == "" ]] \
      && [[ `cat /minecraft/data/logs/latest.log | grep 'Unable to read the jar file Dynmap'` == "" ]]; do
      echo "...Waiting more..."
      sleep 10
    done

    if [[ `cat /minecraft/data/logs/latest.log | grep 'Unable to read the jar file Dynmap'` == "" ]]; then
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

    touch /minecraft/data/dynmap_initialized

  fi
}

# Install
if [[ ! -f /minecraft/data/ServerStart.sh ]]; then

  # Copy install
  cp -fr /minecraft/downloads/* /minecraft/data

fi

# Includ mods port configuration
init_mods

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

# Check launched mods
check_mods

echo -e "\n*************************************************"
echo "* Minecraft server launched. Wait few minutes..."
echo "*************************************************"
wait
