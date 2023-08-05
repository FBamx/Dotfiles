#!/bin/bash

set_network(){
  ovs-vsctl set open_vswitch . \
    external_ids:ovn-remote="tcp:172.29.128.100:6642" \
    external_ids:ovn-encap-ip=$(ip addr show eth0 | awk '$1 == "inet" {print $2}' | cut -f1 -d/) \
    external_ids:ovn-encap-type=geneve \
    external_ids:system-id=$(hostname)

  ovs-vsctl add-port br-int port1 -- \
  set interface port1 \
    type=internal \
    mac='["c0:ff:ee:00:00:11"]' \
    external_ids:iface-id=port1

  ip netns add vm1
  ip link set netns vm1 port1
  ip netns exec vm1 dhclient -v -i port1 --no-pid
}

clean_network(){
  ovs-vsctl del-br br-int
  ip netns del vm1
  ovs-vsctl remove open_vswitch . external_ids ovn-remote
  ovs-vsctl remove open_vswitch . external_ids ovn-encap-ip
  ovs-vsctl remove open_vswitch . external_ids ovn-encap-type
}

if [ "$1" = "set" ]
then
  set_network
elif [ "$1" = "clean" ]
then
  clean_network
else
  echo "invalid argument"
fi
