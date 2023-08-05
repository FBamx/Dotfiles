#!/bin/bash

set_network(){
  ovs-vsctl set open_vswitch . \
    external_ids:ovn-remote="tcp:172.29.128.100:6642" \
    external_ids:ovn-encap-ip=$(ip addr show eth0 | awk '$1 == "inet" {print $2}' | cut -f1 -d/) \
    external_ids:ovn-encap-type=geneve \
    external_ids:system-id=$(hostname)

  ovs-vsctl add-port br-int port2 -- \
  set interface port2 \
    type=internal \
    mac='["c0:ff:ee:00:00:12"]' \
    external_ids:iface-id=port2
  ip netns add vm2
  ip link set netns vm2 port2
  ip netns exec vm2 dhclient -v -i port2 --no-pid

  ovs-vsctl add-port br-int port3 -- \
  set interface port3 \
    type=internal \
    mac='["c0:ff:ee:00:00:13"]' \
    external_ids:iface-id=port3
  ip netns add vm3
  ip link set netns vm3 port3
  ip netns exec vm3 dhclient -v -i port3 --no-pid
}

clean_network(){
  ovs-vsctl del-br br-int
  ip netns del vm3
  ip netns del vm2

  ovs-vsctl remove open_vswitch . external_ids ovn-remote
  ovs-vsctl remove open_vswitch . external_ids ovn-encap-type
  ovs-vsctl remove open_vswitch . external_ids ovn-encap-ip
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
