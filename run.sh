#!/bin/bash

set -e

set_ini_prop() {
    sed "/\[$2\]/,/^\[/ s/$3\=.*/$3=$4/" -i "${GAMECONFIGDIR}/$1"
}

set_ini_val() {
    sed "/\[$2\]/,/^\[/ s/((\"$3\",.*))/((\"$3\", $4))/" -i "/home/steam/$1"
}

# Quick function to generate a timestamp
timestamp () {
  date +"%Y-%m-%d %H:%M:%S,%3N"
}

# Function to handle shutdown when sigterm is received
shutdown () {
    echo ""
    echo "$(timestamp) INFO: Received SIGTERM, shutting down gracefully"
    printf "SaveAndExit 1\r\n" | nc -w 10 127.0.0.1 18888
    sleep 10
    kill -2 $soulmask_pid
}

# Set our trap
trap 'shutdown' TERM

NUMCHECK='^[0-9]+$'
launchDate=`date +"%Y_%m_%d_%H_%M_%s"`

if [ -f "${GAMEPLAYCONFIG}/GameXishu.json" ]; then
    tar cf - "/config/saves" "/config/gameconfigs" "/config/gameplayconfig" "/config/savesAccount" | pigz -9 -p 12 - > "/config/backups/${launchDate}.tar.gz"
fi

mkdir -p "${GAMEBASECONFIGDIR}"

if [ ! -L "${GAMECONFIGDIR}" ]; then
    ln -sf "/config/gameconfigs" "${GAMECONFIGDIR}"
fi

if [ ! -L "${GAMESAVESDIR}" ]; then
    ln -sf "/config/saves" "${GAMESAVESDIR}"
fi

if [ ! -L "${GAMEACCOUNTSAVEDIR}" ]; then
    ln -sf "/config/savesAccount" "${GAMEACCOUNTSAVEDIR}"
fi

if [ ! -L "${GAMEPLAYCONFIG}" ]; then
    ln -sf "/config/gameplayconfig" "${GAMEPLAYCONFIG}"
fi

## Initialise and update files
if ! [[ "${SKIPUPDATE,,}" == "true" ]]; then

    space=$(stat -f --format="%a*%S" .)
    space=$((space/1024/1024/1024))
    printf "Checking available space...%sGB detected\\n" "${space}"

    if [[ "$space" -lt 8 ]]; then
        printf "You have less than 8GB (%sGB detected) of available space to download the game.\\nIf this is a fresh install, it will probably fail.\\n" "${space}"
    fi

    printf "Downloading the latest version of the game...\\n"

    /home/steam/steamcmd/steamcmd.sh +force_install_dir /config/gamefiles +login anonymous +app_update "$STEAMAPPID" +quit
else
    printf "Skipping update as flag is set\\n"
fi

if ! [[ "$MAXPLAYERS" =~ $NUMCHECK ]] ; then
    printf "Invalid max players number given: %s\\n" "${MAXPLAYERS}"
    MAXPLAYERS=32
fi

if ! [[ "${SERVER_ID}" =~ $NUMCHECK ]] ; then
    printf "Invalid server ID: %s\\n" "${MAXPLAYERS}"
    SERVER_ID=1
fi

if ! [[ "$SERVER_PORT" =~ $NUMCHECK ]] ; then
    printf "Invalid server port given: %s\\n" "${SERVER_PORT}"
    SERVER_PORT=8777
fi

if ! [[ "$SERVER_QUERY_PORT" =~ $NUMCHECK ]] ; then
    printf "Invalid server querry given: %s\\n" "${SERVER_QUERY_PORT}"
    SERVER_QUERY_PORT=27015
fi

if [ -f "${GAMECONFIGDIR}/Engine.ini" ]; then
    sed -i "s/saving=\"[^\"]*\"/saving=\"${SAVING}\"/" "/config/gameconfigs/Engine.ini"
    sed -i "s/backup=\"[^\"]*\"/backup=\"${BACKUP}\"/" "/config/gameconfigs/Engine.ini"
    sed -i "s/SteamServerName=\"[^\"]*\"/SteamServerName=\"${SERVER_NAME}\"/" "/config/gameconfigs/Engine.ini"
    sed -i "s/GameServerQueryPort=[0-9]*/GameServerQueryPort=${SERVER_QUERY_PORT}/" "/config/gameconfigs/Engine.ini"
    sed -i "s/Port=[0-9]*/Port=${SERVER_PORT}/" "/config/gameconfigs/Engine.ini"
    sed -i "s/MaxPlayers=[0-9]*/MaxPlayers=${MAXPLAYERS}/" "/config/gameconfigs/Engine.ini"
fi
#bEnablePlayerToPlayerDamage=False,bEnableFriendlyFire=False

LAUNCH_ARGS=""

if [ -n "${SERVERPASSWORD}" ]; then
    LAUNCH_ARGS="${LAUNCH_ARGS} -PSW=\"${SERVERPASSWORD}\""
fi

if [ -n "${SERVERADMINPASSWORD}" ]; then
    LAUNCH_ARGS="${LAUNCH_ARGS} -adminpsw=\"${SERVERADMINPASSWORD}\""
fi

if [ -n "${MAINSERVEURPORT}" ]; then
    LAUNCH_ARGS="${LAUNCH_ARGS} -mainserverport=${MAINSERVEURPORT}"
fi

if [ -n "${TOMAINSERVER}" ]; then
    LAUNCH_ARGS="${LAUNCH_ARGS} -clientserverconnect=${TOMAINSERVER}"
fi

if [ -n "${RCON_PORT}" ] && [ -n "${RCON_PASSWORD}" ]; then
    LAUNCH_ARGS="${LAUNCH_ARGS} -rconpsw=${RCON_PASSWORD} -rconport=${RCON_PORT}"
fi

# Add support for mods
extra_opts=()
if [[ -n $MOD_ID_LIST ]]; then
    extra_opts+=("-mod=\"${MOD_ID_LIST}\"")
    echo "$(timestamp) INFO: Adding mods with ID list: ${MOD_ID_LIST}"
else
    echo "$(timestamp) WARN: No MOD_ID_LIST provided, running without mods"
fi

cd /config/gamefiles || exit 1

exec ./WSServer.sh ${SERVER_LEVEL} -server -SLIENT -log -UTF8Output -serverid=${SERVER_ID} -SteamServerName="${SERVER_NAME}" -Port=${SERVER_PORT} -QueryPort=${SERVER_QUERY_PORT} -${GAME_MODE} -MaxPlayers=${MAXPLAYERS} ${LAUNCH_ARGS} -backup=${BACKUP} -saving=${SAVING} -online=Steam -forcepassthrough ${extra_opts[@]} &

# Capture Soulmask server start script pid
init_pid=$!

# Hold us open until we receive a SIGTERM
wait $init_pid

# Handle post SIGTERM from here
# Hold us open until WSServer-Linux pid closes, indicating full shutdown, then go home
tail --pid=$soulmask_pid -f /dev/null

# o7
echo "$(timestamp) INFO: Shutdown complete. Goodbye, Chieftain."
exit 0