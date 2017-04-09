# A collection of experiments with docker

I have started playing with Docker and I thought it would be a good idea
to share my experiments on GitHub. If you want to know a bit more about
how these experiments have started, see my blog post
"[A dockerized policy hub](http://syslog.me/2016/03/25/a-dockerized-policy-hub/)"

## cf-serverd

Proof of concept of implementing a CFEngine policy hub in a docker container.

To build this image enter the cf-serverd directory and run

```
docker build -t bronto/cf-serverd:3.7.2 .
```

You must provide your own masterfiles in the container's
`/var/cfengine/masterfiles` and a suitable configuration for cf-serverd
in `/var/cfengine/inputs`. You can do that by either mounting a local
filesystem inside the container, or building your own image with the
policy files bundled inside.

You also need to keep the encryption keys so that the clients don't need
to be re-bootstrapped each time you create a new image. Again, you can
mount `/var/cfengine/ppkeys` from a local filesystem, or bundle your set of
encryption keys in the container itself.

This container exposes the port 5308/TCP to make cf-serverd available
outside the container. You'll want to use either the `-P` or the `-p` option
to `docker run`

Refer to the [blog post](http://syslog.me/2016/03/25/a-dockerized-policy-hub/)
for more information.


## debian-systemd

Dockerfile for a debian container running the systemd init system.
Heavily borrowed from
[dockerimages/docker-systemd](https://github.com/dockerimages/docker-systemd/blob/master/15.10/Dockerfile).


You can use it as a base image to build containers that need to run
more than one process.
As such, you probably won't run it alone as it does nothing useful but
starting systemd...

To build this image you'll enter the debian-systemd directory and run:

```
docker build -t bronto/debian-systemd .
```

When you run this image or any container you build upon it, you'll need
**at least** the following options for `docker run`:

```
--cap-add=SYS_ADMIN -v /sys/fs/cgroup:/sys/fs/cgroup:ro
```


## poc-systemd

The whole point of having an init system running in a container is for
those cases where you have processes that expect to log through a
syslog service that is running on the same node. In those cases you
need to run a syslog daemon in addition to the process you want to
"containerize". I was interested in seeing that it is actually possible,
so I built on both the cf-serverd and the debian-systemd containers.

The result is an image whose containers run systemd which, in turn, spawns
CFEngine daemons and a syslog daemon. Like in the other case it does
nothing useful unless you provide masterfiles, configurations for cf-serverd,
and possibly encryption keys.

To build this image you'll enter the debian-systemd directory and run:

```
docker build -t bronto/poc-systemd .
```

When you run this image or any container you build upon it, you'll need
**at least** the following options for `docker run`:

```
--cap-add=SYS_ADMIN -v /sys/fs/cgroup:/sys/fs/cgroup:ro
```

In addition you'll want to use either the `-P` or the `-p` option
to `docker run` to expose cf-serverd outside the container.


## progrium-consul

At the moment, this directory contains only one script: start-single-master.sh.
I use this script to configure a single-node consul server to be used
as a key-value store in experiments with overlay networks.

This script aggregates system information and then runs a docker
container progrium/consul, with a consul server bootstrapped as a
single master.

The container is configured as per instructions found at
https://hub.docker.com/r/progrium/consul/

The variables in the following section allow you to configure some
aspects of the container and of the script itself.

The IP advertised by consul is the IPv4 address set on the interface
through which the default route is configured. Notice that if the
interface has more than one address assigned, the script will likely
break.

As for the IP of the docker bridge, we detect the IPv4 address of
docker0, as indicated in the instructions at the progrium/consul
web page