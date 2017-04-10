#!/bin/bash

########################################################################
# This script starts a consul agent in client mode, joining a master
# whose IP is given as a parameter on the command line. Additional
# options to consul can be also added to the command line after the
# master IP.
#
# Note that no checking is done on the argument. If you pass stupid
# things to the script, please be prepared to live with the
# consequences. I take no responsibility for that.
#
# The consul agent is started according to the information in
# https://github.com/docker-library/docs/tree/master/consul
#
# You can set a few parameters for docker by editing the configuration
# variables below.
########################################################################

### BEGIN CONFIG #######################################################
DEBUG="yes"
CONSUL_NODE_NAME=consul-agent-$HOSTNAME
CONSUL_DIR=/var/local/consul
CONSUL_DATA_DIR=$CONSUL_DIR/data
CONSUL_CONFIG_DIR=$CONSUL_DIR/config
### END CONFIG #########################################################

CONSUL_MASTER="$*"

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
           consul agent -bind=$HOST_IP -retry-join=$CONSUL_MASTER )

if [ "$DEBUG" == "yes" ]
then
    echo "Container ID follows, if any: $CONSUL_CONTAINER_ID"
fi
