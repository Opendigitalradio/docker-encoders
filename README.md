# opendigitalradio/docker-encoders

## Introduction
This repository is part of a project aiming at containerizing the [mmbTools](https://www.opendigitalradio.org/mmbtools) software stack of [Open Digital Radio](https://www.opendigitalradio.org/).

This repository features the following components:
- [audio encoder (v3.2.0)](https://github.com/opendigitalradio/ODR-AudioEnc) 
- [Program Associated Data encoder (v3.0.0)](https://github.com/opendigitalradio/ODR-PadEnc) 
- [supervisor](http://supervisord.org/) 

## Quick setup
1. Get this repository on your host
1. Declare your time zone:
    ```
    TZ=your_time_zone (ex: Europe/Zurich)
    ```
1. Create a docker network:
    ```
    docker network create odr
    ```
1. Run the container. Please note that the image uses port:
    - 8001: supervisor web management interface
    ```
    docker container run \
        --name odr-encoders \
        --detach \
        --rm \
        --network odr \
        --publish 8001:8001 \
        --env "TZ=${TZ}" \
        --volume $(pwd)/odr-data:/odr-data \
        opendigitalradio/encoders:latest \
        /odr-data
    ```
1. Manage the encoders by pointing your web browser to `http://host_running_odr-encoders:8001`
