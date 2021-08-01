# Ubuntu 18.04

This is a docker container template based on the official ubuntu:18.04. It includes several conveniences that help preconfigure the official release for a more complete development environment. It also incluldes configuration that make this ideal to use as a base container for a development environment.  The image includes:

1. Official Release of Ubuntu 18.04.
1. Basic X packages are installed to demonstrate using X11 applications within the container.
1. Docker client is installed and mapped to host's docker socket, allowing docker to be run from within container.
1. Dynamic assignment of permissions, allowing the container to run with credentials of user launching container.

# Quick Start

## Proxy and No_proxy
 
Ensure that the docker daemon is running. If any issue with docker, restart the docker daemon:

```bash
sudo service docker restart
```

## Test
You can test you settings to see if the base container is reachable:

```bash
docker pull ubuntu:18.04
```
 
## Running

To run a bash shell in the container simply run the [example run.sh script].  This script will provide the container
with the credentials of the user launching the container, and attempt to dynamically provision a user in the container
with matching credentials.  With matching credentials, its possible for the volume permissions to be correct and 
properly shared with the user's host:
```bash
run.sh
```

Alternatively you can override the default /bin/bash command by adding additional arguments:
```bash
run.sh xterm
```
If you are going to run an X application, you will need the DISPLAY environment set and you will need an X server running.

# Building

To make image based on the ubuntu base container:
```bash
make build
```

# Additional Details

Additional information for the example

## Running docker side-by-side

The image also contains docker - running in a side by side mode, which allows the ephemeral container access to
the docker cache on the host system, thus enabling the container to invoke any docker command they could on the 
host. This enables the use of docker in a containerized development environment. Once inside the container the
user is able to invoke docker to build images or run other containers that are part of your development toolchain.

In order to accomplish this, the image includes an installation of docker and the host's docker socket is mapped
into the container from the docker run command:
```bash
docker run ... \
    -e DOCKER_GID=998 \
    -v /var/run/docker.sock:/var/run/docker.sock ...
```
Additionally the host's docker group id are passed to the container so the dynamic permissions will enable the user
to run docker commands inside the container without needing to prefix each command with sudo.
```bash
container> docker images
```


## Running GUI apps with Docker

There are a number of ways you can run X11 applications from within your containers,
some less portable than others. For this example we will mount the X11 socket and 
setup the DISPLAY environment variable.  

Because we are also mapping the credentials of the running user, we have the proper 
permissions for the user's HOME directory and their XAuthority file. If we choose
not to map the home directory in, we would need to handle the authorization differently.

```bash
docker run --rm -it \
    -e DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    --net=host \
    -e USER=vagrant \
    -e USER_ID=1000 \
    -e GROUP=vagrant \
    -e GROUP_ID=1000 \
    -e DOCKER_GID=998 \
    -v /home/vagrant:/home/vagrant \
    -v /var/run/docker.sock:/var/run/docker.sock \
    aiot20/ubuntu18.04:latest /bin/bash
```
Note: Many of the parameters passed into docker are automatically computed by the example
run.sh. The script will fill in all information about the user's identity (uid/gid 
information along with the gid of the docker group in the host).

The --net-host is useful for development containers, but it not necessary.

## Permissions

The image contains an example of dynamically assumming the credentials of the running user - so the permissions on 
the mounted volumes are correct. This dynamically created user has sudo if they need.

## PID 1 problem

From a signaling perspective - docker containers also face challenges with the PID 1 problem: reaping zombies.
Unix processes are ordered in a tree, where the parent/child relationship is maintained. The container provisioning
ensures the requested application is run under PID=1, allowing the signals to be passed through from the host.
