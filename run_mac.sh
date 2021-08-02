#!/bin/bash

# Grab the current user's uid and gid information
USER_ID=$(id -u)
GROUP_ID=$(id -g)
GROUP=$(id -ng)
DOCKER_GID=
CNAME=${USER}_$(date +%m%d_%H%m%S)

# Set the display
if [ "$(uname)" == "Darwin" ]; then
    ip=$(ifconfig en0 | grep inet | awk '$1=="inet" {print $2}')
    xhost + $ip
    xsession="-e DISPLAY=$ip:0 -v /tmp/.X11-unix:/tmp/.X11-unix"
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    DOCKER_GID=$(cut -d: -f3 < <(getent group docker))
    xsession="-e DISPLAY \
              -v /tmp/.X11-unix:/tmp/.X11-unix"
else
    echo "Unsupported Platform: " $(uname)
    exit 1
fi

# Example configuration to run container that mapps in he user's identity
# along with their home directory, allowign them to run X applications and
# docker, without requring sudo
#    --device /dev/dri \
#    --device /dev/snd \

docker run --rm -it \
    $xsession \
    --net=host \
    --workdir=$(pwd) \
    --name=$CNAME \
    -e USER=$USER \
    -e USER_ID=$USER_ID \
    -e GROUP=$GROUP \
    -e GROUP_ID=$GROUP_ID \
    -v $HOME:$HOME \
    -v /var/run/docker.sock:/var/run/docker.sock \
    hazmap/ubuntu18.04:latest \
    "$@"
