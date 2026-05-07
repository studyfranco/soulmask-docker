<div align="center">
  
![Github stars](https://badgen.net/github/stars/studyfranco/soulmask-docker?icon=github&label=stars)
![Github forks](https://badgen.net/github/forks/studyfranco/soulmask-docker?icon=github&label=forks)
![Github issues](https://img.shields.io/github/issues/studyfranco/soulmask-docker)
![Github last-commit](https://img.shields.io/github/last-commit/studyfranco/soulmask-docker)
  
</div>

# Palworld Dedicated Server

Hello and welcome! Hopefully this can help anyone get up and running with Soulmask!

Issues are welcome but pull requests are even more welcome if you can!

## Specials thanks

My work are based on the docker server of satisfactory from [wolveix](https://github.com/wolveix/satisfactory-server)

And I adapted for soulmask with the work of [jsknnr](https://github.com/jsknnr/soulmask-dedicated-server)

## Background

I spun this up initially because well like anyone else, I wanted to run a dedicated server, but with a docker images who can edit the configuration ini.

This image is based on cm2network/steamcmd image and built out using a combination of help from the satisfactory and valheim images using the same base.

I used my previous scripts from Frozen Flame, and now you have this image.

## Setup

For people who want use the image you can use [docker compose](https://docs.docker.com/compose/) up -d:

```yaml
services:
  soulmask:
    container_name: soulmask-server
    hostname: soulmask-server
    image: ghcr.io/studyfranco/soulmask-docker:master
    #network_mode: "host"
    volumes:
      - "/path/to/config:/config"
    ports:
      - 8777:8777/udp
      - 27015:27015/udp
      #- 27017:27017/udp
    expose:
      - 8211/udp
      - 27015/udp
      #- 27017/udp
    environment:
      - "SERVER_NAME=SoulmaskServerByMe"
      - "SERVER_PORT=8777"
      - "SERVER_QUERY_PORT=27015"
      #- "RCON_PORT=25575"
      #- "RCON_PASSWORD=password"
      - "MAXPLAYERS=32"
      - "SERVERPASSWORD=password"
      - "SERVERADMINPASSWORD=password"
      - "PUID=2198"
      - "PGID=2198"
      - "BACKUP=900"
      - "SAVING=600"
      - "GAME_MODE=pve"
      - "MOD_ID_LIST="
      - "TZ=Etc/UTC"
    tmpfs:
      - "/run:exec,mode=777"
      - "/tmp:exec,mode=777"
      - "/tmp/dumps:exec,mode=777"
      - "/var/tmp:exec,mode=777"
      - "/config/gamefiles/steamapps/temp:uid=2198,gid=2198"
    restart: "unless-stopped"
```

You can use the safer way with ports forwarding, or the network mod host.

Or you can use a quick and dirty `docker run`:

```bash
run -d --net=host -v </path/to/config>:/config --name=soulmask-server ghcr.io/studyfranco/soulmask-docker:master 
```

This is currently using the host network simplicity but you should be able to map the ports how you wish without it, but that's untested by me.

## Environment Variables

| Parameter               |  Default  | Function                                            |
| ----------------------- | :-------: | --------------------------------------------------- |
| `SERVER_NAME`           | `SoulmaskServerByMe` | set the name of the server               |
| `SERVER_PORT`           |   `8777`  | Sets custom Game port. This is used by client to connect |
| `SERVER_QUERY_PORT`     |  `27015`  | Sets custom Query Port. Used by Steam to get server info |
| `SERVERPASSWORD`        | `password`| Set server password                                 |
| `SERVERADMINPASSWORD`   | `password`| Set server Admin password                           |
| `RCON_PORT`             |  `25575`  | Set Rcon port                                       |
| `RCON_PASSWORD`         | `password`| Set Rcon password                                   |
| `MAXPLAYERS`            |    `32`   | set the player limit for your server                |
| `PGID`                  |   `2198`  | set the group ID of the user the server will run as |
| `PUID`                  |   `2198`  | set the user ID of the user the server will run as  |

## Features in this docker

- Backup at each start
- Automatic edition of basic server game configs

I am open to improve some features

## Improve your experiences

You can edit the /config/gameconfigs/Engine.ini to choose somes other options.

## Last Update
2026-05-07
2026-04-15
