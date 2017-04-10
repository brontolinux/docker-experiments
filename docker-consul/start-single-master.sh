#!/bin/bash

########################################################################
# This script aggregates system information and then runs a docker
# container progrium/consul, with a consul server bootstrapped as a
# single master.
#
# The container is configured as per instructions found at
# https://github.com/docker-library/docs/tree/master/consul
#
# The variables in the following section allow you to configure some
# aspects of the container and of the script itself.
#
# The IP advertised by consul is the IPv4 address set on the interface
# through which the default route is configured. Notice that if the
# interface has more than one address assigned, the script will likely
# break.
########################################################################

### BEGIN CONFIG #######################################################
DEBUG="yes"
CONSUL_NODE_NAME=consul-node-1
CONSUL_DIR=/var/local/consul
CONSUL_DATA_DIR=$CONSUL_DIR/data
CONSUL_CONFIG_DIR=$CONSUL_DIR/config
DNS_RECURSOR=80.80.80.80
### END CONFIG #########################################################

DEFAULT_IF=$( ip route show | awk '/^default/ { print $5 }' )
HOST_IP_MASK=$( ip -o addr show dev $DEFAULT_IF | awk '$3~/^inet$/ { print $4 }' )
HOST_IP=${HOST_IP_MASK%%/??}

if [ "$DEBUG" == "yes" ]
then
    echo "Default route on interface $DEFAULT_IF"
    echo "The IPv4 address on $DEFAULT_IF is $HOST_IP"
    echo "The data directory for consul is $CONSUL_DATA_DIR"
    echo "The config directory for consul is $CONSUL_CONFIG_DIR"
fi

mkdir -p $CONSUL_DATA_DIR   2> /dev/null
mkdir -p $CONSUL_CONFIG_DIR 2> /dev/null


CONSUL_CONTAINER_ID=$( \
    docker run --rm -d \
           -h $CONSUL_NODE_NAME \
           -v $CONSUL_DATA_DIR:/consul/data \
           -v $CONSUL_CONFIG_DIR:/consul/config \
           --name $CONSUL_NODE_NAME \
           --net=host \
           -e 'CONSUL_ALLOW_PRIVILEGED_PORTS=' \
           consul agent -server -bind $HOST_IP -dns-port=53 -recursor $DNS_RECURSOR -bootstrap -ui )

if [ "$DEBUG" == "yes" ]
then
    echo "Container ID follows, if any: $CONSUL_CONTAINER_ID"
    echo "Web UI available at http://127.0.0.1:8500/ui"
    echo "DNS server available at 127.0.0.1 port 53 (TCP/UDP)"
fi
