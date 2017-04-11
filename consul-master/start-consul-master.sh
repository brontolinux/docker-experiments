#!/bin/bash

########################################################################
# This script aggregates system information and then runs a consul
# server bootstrapped as a single master.
#
# The variables in the following section allow you to configure some
# aspects of the server and of the script itself.
#
# The IP advertised by consul is the IPv4 address set on the interface
# through which the default route is configured. Notice that if the
# interface has more than one address assigned, the script will likely
# break.
########################################################################

### BEGIN CONFIG #######################################################
DEBUG="yes"
CONSUL_NODE_NAME=consul-master-$HOSTNAME
CONSUL_DIR=$PWD
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
    echo "Web UI available at http://$HOST_IP:8500/ui"
    echo "DNS server available at $HOST_IP port 8600 (TCP/UDP)"
fi

mkdir -p $CONSUL_DATA_DIR   2> /dev/null
mkdir -p $CONSUL_CONFIG_DIR 2> /dev/null

$CONSUL_DIR/bin/consul agent \
                       -server \
                       -bind $HOST_IP \
                       -client $HOST_IP \
                       -data-dir $CONSUL_DATA_DIR \
                       -config-dir $CONSUL_CONFIG_DIR \
                       -node $CONSUL_NODE_NAME \
                       -bootstrap \
                       -ui 

