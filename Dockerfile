FROM cm2network/steamcmd:root

LABEL maintainer="studyfranco@hotmail.fr"

RUN set -x \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y gosu pigz --no-install-recommends\
    && rm -rf /var/lib/apt/lists/*  \
    && rm -rf /var/log/* \
    && gosu nobody true

RUN mkdir -p /config \
    && chown steam:steam /config

COPY init.sh /

COPY --chown=steam:steam *.ini run.sh /home/steam/

WORKDIR /config

ENV SERVER_NAME="SoulmaskServerByMe" \
    SERVER_PORT=8777 \
    SERVER_QUERY_PORT=27015 \
    RCON_PORT= \
    RCON_PASSWORD= \
    STEAMAPPID=3017300 \
    MAXPLAYERS=32 \
    SERVERPASSWORD="password" \
    SERVERADMINPASSWORD="password" \
    PUID=2198 \
    PGID=2198 \
    GAMEBASECONFIGDIR="/config/gamefiles/WS/Saved/Config" \
    GAMECONFIGDIR="/config/gamefiles/WS/Saved/Config/LinuxServer" \
    GAMESAVESDIR="/config/gamefiles/WS/Saved/Worlds" \
    BACKUP=900 \
    SAVING=600 \
    SKIPUPDATE="false" \
    GAME_MODE="pve" \
    SERVER_LEVEL="Level01_Main" \
    SERVER_ID=1 \
    MAINSERVEURPORT=20000 \
    TOMAINSERVER= \
    MOD_ID_LIST=

ENTRYPOINT [ "/init.sh" ]
