#! /usr/bin/env python3

import os
import sys
import datetime
import zipfile
import shutil
import argparse


minecraft_data = "/minecraft/data"
minecraft_bin = "/minecraft/bin"


def recursive_copy(src, dst):
    for item in os.listdir(src):

        if os.path.isfile(src + "/" + item):
            shutil.copy(src + "/" + item, dst)

        elif os.path.isdir(src + "/" + item):
            new_dst = os.path.join(dst, item)
            if not os.path.isdir(new_dst):
                os.mkdir(new_dst)
            recursive_copy(os.path.abspath(src + "/" + item), new_dst)


def resources_update():

    global minecraft_bin
    global minecraft_data

    minecraft_bin = "/home/docker/minecraft_files_ftbrev_dev/exchange"
    minecraft_temp = "/home/docker/minecraft_files_ftbrev_dev/tmp"
    minecraft_data = "/home/docker/minecraft_files_ftbrev_dev/output"

    # minecraft_bin = "C:/Users/NG77B6B/PyCharmProjects/ovh"
    # minecraft_temp = "C:/Users/NG77B6B/PyCharmProjects/ovh/tmp"
    # minecraft_data = "C:/Users/NG77B6B/PyCharmProjects/ovh/output"

    if os.path.isfile(minecraft_data + "/dynmap.jar"):
        print "Final dynmap.jar deletion"
        os.remove(minecraft_data + "/dynmap.jar")

    if os.path.isdir(minecraft_temp):
        print "Temp directories deletion"
        shutil.rmtree(minecraft_temp)

    print "Temp directories creation"
    os.mkdir(minecraft_temp)
    os.mkdir(minecraft_temp + "/dynmap")
    os.mkdir(minecraft_temp + "/textures")

    print "Extract mods"
    list_jar = os.listdir(minecraft_bin + "/mods/")
    for jarfile in list_jar:
        if os.path.isfile(minecraft_bin + "/mods/" + jarfile):
            print "  Extraction of " + jarfile
            if jarfile == "dynmap.jar":
                with zipfile.ZipFile(minecraft_bin + "/mods/" + jarfile) as z:
                    z.extractall(
                        path=minecraft_temp + "/dynmap"
                    )
            else:
                with zipfile.ZipFile(minecraft_bin + "/mods/" + jarfile) as z:
                    z.extractall(
                        path=minecraft_temp + "/textures"
                    )
        else:
            print "  No extraction for directory " + jarfile

    print "Concatenate resources"
    # 1rst Try => Get Only texture data
    list_resources = os.listdir(minecraft_temp + "/textures/assets")
    for resource in list_resources:
        if os.path.isdir(minecraft_temp + "/textures/assets/" + resource + "/textures"):
            print "  Copy {0}...".format(resource)
            try:
                recursive_copy(
                    minecraft_temp + "/textures/assets/" + resource + "/textures",
                    minecraft_temp + "/dynmap/texturepacks/standard/assets/minecraft/textures")
            except OSError as e:
                print('  Directory not copied. Error: %s' % e)

    # 2nd Rty => Get all assets data
    # recursive_copy(
    #     minecraft_temp + "/textures/assets",
    #     minecraft_temp + "/dynmap/texturepacks/standard/assets")

    # 3rd Try => Get Only blocks data
    # list_resources = os.listdir(minecraft_temp + "/textures/assets")
    # for resource in list_resources:
    #     if os.path.isdir(minecraft_temp + "/textures/assets/" + resource + "/textures/blocks"):
    #         print "  Copy {0}...".format(resource)
    #         try:
    #             recursive_copy(
    #                 minecraft_temp + "/textures/assets/" + resource + "/textures/blocks",
    #                 minecraft_temp + "/dynmap/texturepacks/standard/assets/minecraft/textures/blocks")
    #         except OSError as e:
    #             print('  Directory not copied. Error: %s' % e)

    print "JAR Creation"
    output_jar = zipfile.ZipFile(minecraft_data + "/dynmap.jar", "w")
    os.chdir(minecraft_temp + "/dynmap")

    def jar_recursive(source, final_jar):
        if os.path.isfile(source):
            final_jar.write(source)
        else:
            for sub_element in os.listdir(source):
                jar_recursive(source + "/" + sub_element, final_jar)

    for element in os.listdir(minecraft_temp + "/dynmap"):
        jar_recursive(element, output_jar)

    output_jar.close()


def send_command(input_command=None):
    if input_command is not None:
        final_command = "tmux send-keys -t minecraft '" + input_command + "' C-m"

        print (
            "Command [{0}] will be send...".format(final_command)
        )

        os.popen(
            "{0}".format(final_command)
        ).read()


def config_file():

    global minecraft_data

    properties = {
        "allow-flight": os.getenv(
            "ALLOW_FLIGHT", "false"),
        "allow-nether": os.getenv(
            "ALLOW_NETHER", "true"),
        "difficulty": os.getenv(
            "DIFFICULTY", 1),
        "enable-command-block": os.getenv(
            "ENABLE_COMMAND_BLOCK", "false"),
        "enable-query": os.getenv(
            "ENABLE_QUERY", "false"),
        "enable-rcon": os.getenv(
            "ENABLE_RCON", "false"),
        "force-gamemode": os.getenv(
            "FORCE_GAMEMODE", "false"),
        "gamemode": os.getenv(
            "GAMEMODE", 0),
        "generate-structures": os.getenv(
            "GENERATE_STRUCTURES", "true"),
        "generator-settings": os.getenv(
            "GENERATOR_SETTINGS"),
        "hardcore": os.getenv(
            "HARDCORE", "false"),
        "level-name": os.getenv(
            "LEVEL_NAME", "world"),
        "level-seed": os.getenv(
            "LEVEL_SEED"),
        "level-type": os.getenv(
            "LEVEL_TYPE", "DEFAULT"),
        "max-build-height": os.getenv(
            "MAX_BUILD_HEIGHT", 256),
        "max-players": os.getenv(
            "MAX_PLAYERS", 20),
        "max-tick-time": os.getenv(
            "MAX_TICK_TIME", 6000000),
        "max-world-size": os.getenv(
            "MAX_WORLD_SIZE", 29999984),
        "motd": os.getenv(
            "MOTD"),
        "network-compression-threshold": os.getenv(
            "NETWORK_COMPRESSION_THRESHOLD", 256),
        "online-mode": os.getenv(
            "ONLINE_MODE", "true"),
        "os-permission-level": os.getenv(
            "OP_PERMISSION_LEVEL", 4),
        "player-idle-timeout": os.getenv(
            "PLAYER_IDLE_TIMEOUT", 0),
        "prevent-proxy-connections": os.getenv(
            "PREVENT_PROXY_CONNECTIONS", "false"),
        "pvp": os.getenv(
            "PVP", "true"),
        "resource-pack": os.getenv(
            "RESOURCE_PACK"),
        "resource-pack-sha1": os.getenv(
            "RESOURCE_PACK_SHA1"),
        "server-ip": os.getenv(
            "SERVER_IP"),
        "server-port": os.getenv(
            "SERVER_PORT", 25565),
        "snooper-enabled": os.getenv(
            "SNOOPER_ENABLED", "true"),
        "spawn-animals": os.getenv(
            "SPAWN_ANIMALS", "true"),
        "spawn-monsters": os.getenv(
            "SPAWN_MONSTERS", "true"),
        "spawn-npcs": os.getenv(
            "SPAWN_NPCS", "true"),
        "view-distance": os.getenv(
            "VIEW_DISTANCE", 10),
        "white-list": os.getenv(
            "WHITE_LIST", "false")
    }

    with open(minecraft_data + "/server.properties", 'w') as f:
        now = datetime.datetime.now().isoformat()

        f.write("# Minecraft server properties\n")
        f.write("# Automatically generated at {}\n\n".format(now))

        for k, v in properties.items():
            if not v:
                f.write('{}:\n'.format(k))
            elif isinstance(v, (int)):
                f.write('{}: {}\n'.format(k, v))
            else:
                f.write('{}: {}\n'.format(k, v))


if __name__ == "__main__":

    # Check arguments
    parser = argparse.ArgumentParser(description='Minecraft configuration tools.')

    parser.add_argument('-c', '--config',
                        help='creation of server.properties file',
                        action="store_true")
    parser.add_argument('-C', '--command',
                        help='sending command in server command admin')
    parser.add_argument("-v", "--verbose",
                        help='active logs',
                        action="store_true")

    if (
            parser.parse_args().config is False and
            parser.parse_args().command is None
    ):
        parser.print_help()
    else:

        if parser.parse_args().config:
            config_file()

        if parser.parse_args().command:
            send_command(parser.parse_args().command)
