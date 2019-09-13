# Minecraft - Docker

__*Take care, `Last` version is often in dev. Use stable version with TAG*__

Docker build for managing a Minecraft Fead the Beast Revelation server with optionnal multiple modul include as:
- Dynmap-3.0-beta-3-forge-1.12.2
  + DynmapBlockScan-3.0-beta-1-forge-1.12.2
- buildcraft-all-7.99.21
- energyconverters_1.12.2-1.2.1.11.jar

To activate mods, you need to set "YES" for linked environment variable.
/!\ DynmapBlockScan need Dynmap to process. Without server crash.
By default, there are not active.

This image is borrowed from JonasBonno/docker-ftb-revelation functionnalities.
Thanks for this good base of Dockerfile and existing structure.

This image uses [FTBRevelationServer in 2.7.0](https://media.forgecdn.net/files/2658/240/FTBRevelationServer_2.7.0.zip) to install and manage a Minecraft server.

---

## Features
 - Easy install
 - Easy port configuration
 - Easy access to Minecraft config file
 - `Docker stop` is a clean stop

---

## Variables

A full list of `server.properties` settings and their corresponding environment variables is included below, along with their defaults:

| Configuration Option          | Environment Variable          | Default                  |
| ------------------------------|-------------------------------|--------------------------|
| allow-flight                  | ALLOW_FLIGHT                  | `false`                  |
| allow-nether                  | ALLOW_NETHER                  | `true`                   |
| difficulty                    | DIFFICULTY                    | `1`                      |
| enable-command-block          | ENABLE_COMMAND_BLOCK          | `false`                  |
| enable-query                  | ENABLE_QUERY                  | `false`                  |
| enable-rcon                   | ENABLE_RCON                   | `false`                  |
| force-gamemode                | FORCE_GAMEMODE                | `false`                  |
| gamemode                      | GAMEMODE                      | `0`                      |
| generate-structures           | GENERATE_STRUCTURES           | `true`                   |
| generator-settings            | GENERATOR_SETTINGS            |                          |
| hardcore                      | HARDCORE                      | `false`                  |
| level-name                    | LEVEL_NAME                    | `world`                  |
| level-seed                    | LEVEL_SEED                    |                          |
| level-type                    | LEVEL_TYPE                    | `DEFAULT`                |
| max-build-height              | MAX_BUILD_HEIGHT              | `256`                    |
| max-players                   | MAX_PLAYERS                   | `20`                     |
| max-tick-time                 | MAX_TICK_TIME                 | `6000000`                |
| max-world-size                | MAX_WORLD_SIZE                | `29999984`               |
| motd                          | MOTD                          | `"Welcome to Minecraft"` |
| network-compression-threshold | NETWORK_COMPRESSION_THRESHOLD | `256`                    |
| online-mode                   | ONLINE_MODE                   | `true`                   |
| op-permission-level           | OP_PERMISSION_LEVEL           | `4`                      |
| player-idle-timeout           | PLAYER_IDLE_TIMEOUT           | `0`                      |
| prevent-proxy-connections     | PREVENT_PROXY_CONNECTIONS     | `false`                  |
| pvp                           | PVP                           | `true`                   |
| resource-pack                 | RESOURCE_PACK                 |                          |
| resource-pack-sha1            | RESOURCE_PACK_SHA1            |                          |
| server-ip                     | SERVER_IP                     |                          |
| server-port                   | SERVER_PORT                   | `25565`                  | 
| snooper-enabled               | SNOOPER_ENABLED               | `true`                   |
| spawn-animals                 | SPAWN_ANIMALS                 | `true`                   |
| spawn-monsters                | SPAWN_MONSTERS                | `true`                   |
| spawn-npcs                    | SPAWN_NPCS                    | `true`                   |
| view-distance                 | VIEW_DISTANCE                 | `10`                     |
| white-list                    | WHITE_LIST                    | `false`                  |

---

## Usage

### Run of the server

To start the server and accept the EULA in one fell swoop, just pass the `EULA=true` environment variable to Docker when running the container.

`docker run -it -p 25565:25565 -e EULA=true --name minecraf_server mdestombes/minecraft_ftbrev_server`

### Configuration

You should be able to pass configuration options as environment variables like so:
`docker run -it -p 25565:25565 -p 8123:8123 -e EULA=true -e DIFFICULTY=2 -e MOTD="A specific welcome message" -e SPAWN_ANIMALS=false --name minecraf_server mdestombes/minecraft_ftbrev_server`

This container will attempt to generate a `server.properties` file if one does not already exist. If you would like to use the configuration tool, be sure that you are not providing a configuration file or that you also set `FORCE_CONFIG=true` in the environment variables.

### Activation of Dynmap

You should be able to active Dynmap mod, or others, by setting "YES" to linked enviroment variable, as:

`docker run -it -p 25565:25565 -p 8123:8123 -e EULA=true -e WITH_DYNMAP="YES" --name minecraf_server mdestombes/minecraft_ftbrev_server`

/!\ Dynmap mod need another open port.

### Changing default port

You should be able to changing default port of your server by changin linked environment variable, as:

`docker run -it -p 25575:25575 -p 8133:8133 -e EULA=true -e SERVER_PORT=25575 -e DYNMAP_PORT=8133 -e WITH_DYNMAP="YES" --name minecraf_server mdestombes/minecraft_ftbrev_server`

/!\ Dynmap mod need another open port.

### Environment Files

Because of the potentially large number of environment variables that you could pass in, you might want to consider using an `environment variable file`. Example:
```
# env.list
ALLOW_NETHER=false
level-seed=123456789
EULA=true
```

`docker run -it -p 25565:25565 -p 8123:8123 --env-file env.list --name minecraf_server mdestombes/minecraft_ftbrev_server`

### Saved run of the server

You can bring your own existing data + configuration and mount it to the `/data` directory when starting the container by using the `-v` option.

`docker run -it -v /my/path/to/minecraft:/minecraft/data/:rw -p 25565:25565 -p 8123:8123 -e EULA=true --name minecraf_server mdestombes/minecraft_ftbrev_server`

---

## Recommended Usage

---

## Importants point in available volumes
+ __/minecraft/data__: Working data directory wich contains:
  + /minecraft/data/dynmap: Dynmap modul directory
    + /minecraft/data/dynmap/configuration.txt: Configuration file of Dynmap
  + /minecraft/data/logs: Logs directory
  + /minecraft/data/mods: Others moduls directory
  + /minecraft/data/server.properties: Minecraft server properties

---

## Expose
+ Port: __SERVER_PORT__: Minecraft steam port (default: 25565)
+ Port: __DYNMAP_PORT__: Main server port (default: 8123)
+ Port: __WITH_DYNMAP__: Mod Dynmap activation managment (default: "NO")
+ Port: __WITH_BUILDCRAFT__: Mod Buildcraft activation managment (default: "NO")
+ Port: __WITH_BLOCKSCAN__: Mod Dynmap Blockscan activation managment (default: "NO")
+ Port: __WITH_ENERGY__: Mod Energy Converter activation managment (default: "NO")

---

## Known issues

---

## Changelog

| Tag      | Notes                   |
|----------|-------------------------|
| `1.0`    | Initialization          |
|----------|-------------------------|
| `1.1`    | Mods are optionnal      |
