#!/bin/bash

########################################################################
# This script aggregates system information and then runs a docker
# container progrium/consul, with a consul server bootstrapped as a
# single master.
#
# The container is configured as per instructions found at
# https://hub.docker.com/r/progrium/consul/
#
# The variables in the following section allow you to configure some
# aspects of the container and of the script itself.
#
# The IP advertised by consul is the IPv4 address set on the interface
# through which the default route is configured. Notice that if the
# interface has more than one address assigned, the script will likely
# break.
#
# As for the IP of the docker bridge, we detect the IPv4 address of
# docker0, as indicated in the instructions at the progrium/consul
# web page
########################################################################

### BEGIN CONFIG #######################################################
DEBUG="yes"
CONSUL_NODE_NAME=consul-node-1
CONSUL_DATA_DIR=/var/local/consul/data
### END CONFIG #########################################################

DEFAULT_IF=$( ip route show | awk '/^default/ { print $5 }' )
HOST_IP_MASK=$( ip -o addr show dev $DEFAULT_IF | awk '$3~/^inet$/ { print $4 }' )
HOST_IP=${HOST_IP_MASK%%/??}

DOCKER_BRIDGE_IP_MASK=$( ip -o addr show dev docker0 | awk '$3~/^inet$/ { print $4 }' )
DOCKER_BRIDGE_IP=${DOCKER_BRIDGE_IP_MASK%%/??}


if [ "$DEBUG" == "yes" ]
then
    echo "Default route on interface $DEFAULT_IF"
    echo "The IPv4 address on $DEFAULT_IF is $HOST_IP"
    echo "The IPv4 address of the docker bridge is $DOCKER_BRIDGE_IP"
    echo "The data directory for consul is $CONSUL_DATA_DIR"
fi

mkdir -p $CONSUL_DATA_DIR 2> /dev/null

CONSUL_CONTAINER_ID=$( docker run --rm -d \
       -h $CONSUL_NODE_NAME \
       -v $CONSUL_DATA_DIR:/data \
       --name $CONSUL_NODE_NAME \
       -p $HOST_IP:8300:8300 \
       -p $HOST_IP:8301:8301 \
       -p $HOST_IP:8301:8301/udp \
       -p $HOST_IP:8302:8302 \
       -p $HOST_IP:8302:8302/udp \
       -p $HOST_IP:8400:8400 \
       -p $HOST_IP:8500:8500 \
       -p $DOCKER_BRIDGE_IP:53:53/udp \
       progrium/consul -server -advertise $HOST_IP -bootstrap -ui-dir /ui )

if [ "$DEBUG" == "yes" ]
then
    echo "Container ID follows, if any: $CONSUL_CONTAINER_ID"
    echo "Web UI available at http://$HOST_IP:8500/ui"
    echo "DNS server available at $DOCKER_BRIDGE_IP port 53 (TCP/UDP)"
fi
