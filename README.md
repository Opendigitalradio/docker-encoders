# opendigitalradio/docker-encoders

## Introduction
This repository is part of a project aiming at containerizing the [mmbTools](https://www.opendigitalradio.org/mmbtools) software stack of [Open Digital Radio](https://www.opendigitalradio.org/).

This repository features the following components:
- [audio encoder](https://github.com/opendigitalradio/ODR-AudioEnc) 
- [PAD (Program Associated Data) encoder](https://github.com/opendigitalradio/ODR-PadEnc) 
- [supervisor](http://supervisord.org/) 

## Setup
In order to allow for data persistence and data sharing among the various mmbTools containers, please follow these instructions:
1. Create a temporary `odr-data` directory structure on your host:
    ```
    mkdir --parents \
        ${HOME}/odr-data/mot \
        ${HOME}/odr-data/supervisor
    ```
1. Declare your time zone:
    ```
    TZ=your_time_zone (ex: Europe/Zurich)
    ```
1. Check your supervisor jobs file(s):
    - Don't define a user and a group
    - Verify the output URL of the audio encoders jobs. If the mux component runs inside a container, the host name is the mux container name (provided mux and encoders containers run in the same docker network)
    - Verify the path of options `--dls`, `--dir` and `--write-icy-text`. They should all start with `/odr-data`
1. Copy your supervisor jobs file(s) into the temporary `odr-data` directory:
    ```
    # case-1: you have supervisor jobs file(s)
    cp your_supervisor_jobs_files ${HOME}/odr-data/supervisor

    # case-2: you don't have supervisor jobs file(s)
    cp ./odr-data/supervisor/ODR-encoders.conf ${HOME}/odr-data/supervisor
    ```
1. Copy your PAD-related files into the directory structure:
    ```
    # case-1: you have a PAD-related directory
    cp your_PAD_related_directory/ ${HOME}/odr-data/mot

    # case-2: you don't have a PAD-related directory
    cp -r ./odr-data/mot/* ${HOME}/odr-data/mot
    ```
1. Create a docker network:
    ```
    docker network create odr
    ```

## Run
1. Create the container that will be started later. Please note that the image uses port:
    - 8001: supervisor web management interface
    ```
    docker container create \
        --name odr-encoders \
        --env "TZ=${TZ}" \
        --volume odr-data:/odr-data \
        --network odr \
        --publish 8001:8001 \
        opendigitalradio/encoders:latest
    ```
1. Copy the temporary `odr-data` directory to the container:
    ```
    docker container cp ${HOME}/odr-data odr-encoders:/
    ```
1. Start the container 
    ```
    docker container start odr-encoders
    ```
1. Manage the encoders by pointing your web browser to `http://host_running_odr-encoders:8001`
