#!/bin/bash

set_network() {

  ovn-sbctl set-connection ptcp:6642

  ovs-vsctl set open_vswitch . \
    external_ids:ovn-remote=tcp:172.29.128.100:6642 \
    external_ids:ovn-encap-ip=$(ip addr show eth0 | awk '$1 == "inet" {print $2}' | cut -f1 -d/) \
    external_ids:ovn-encap-type=geneve \
    external_ids:system-id=$(hostname)

  ovn-nbctl ls-add net0
  ovn-nbctl ls-add net1
  
  ovn-nbctl set logical_switch net0 \
    other_config:subnet="10.0.0.0/24" \
    other_config:exclude_ips="10.0.0.1..10.0.0.10"

  ovn-nbctl set logical_switch net1 \
    other_config:subnet="10.0.1.0/24" \
    other_config:exclude_ips="10.0.1.1..10.0.1.10"

  ovn-nbctl dhcp-options-create 10.0.0.0/24
  CIDR_UUID=$(ovn-nbctl --bare --columns=_uuid find dhcp_options cidr="10.0.0.0/24")
  ovn-nbctl dhcp-options-set-options $CIDR_UUID \
    lease_time=3600 \
    router=10.0.0.1 \
    server_id=10.0.0.1 \
    server_mac=52:54:00:c1:68:53

  ovn-nbctl dhcp-options-create 10.0.1.0/24
  CIDR_UUID1=$(ovn-nbctl --bare --columns=_uuid find dhcp_options cidr="10.0.1.0/24")
  ovn-nbctl dhcp-options-set-options $CIDR_UUID1 \
    lease_time=3600 \
    router=10.0.1.1 \
    server_id=10.0.1.1 \
    server_mac=52:54:00:c1:68:51

  ovn-nbctl lsp-add net0 port1
  ovn-nbctl lsp-set-addresses port1 "c0:ff:ee:00:00:11 dynamic"
  ovn-nbctl lsp-set-dhcpv4-options port1 $CIDR_UUID
  ovn-nbctl set logical_switch_port port1 tag=100

  ovn-nbctl lsp-add net0 port2
  ovn-nbctl lsp-set-addresses port2 "c0:ff:ee:00:00:12 dynamic"
  ovn-nbctl lsp-set-dhcpv4-options port2 $CIDR_UUID
  ovn-nbctl set logical_switch_port port2 tag=200

  ovn-nbctl lsp-add net1 port3
  ovn-nbctl lsp-set-addresses port3 "c0:ff:ee:00:00:13 dynamic"
  ovn-nbctl lsp-set-dhcpv4-options port3 $CIDR_UUID1

  ovn-nbctl lr-add r1
  ovn-nbctl lrp-add r1 r1-net0 52:54:00:c1:68:50 10.0.0.1/24
  ovn-nbctl lrp-add r1 r1-net1 52:54:00:c1:68:51 10.0.1.1/24

  ovn-nbctl lsp-add net0 net0-r1
  ovn-nbctl lsp-set-addresses net0-r1 52:54:00:c1:68:50
  ovn-nbctl lsp-set-type net0-r1 router
  ovn-nbctl lsp-set-options net0-r1 router-port=r1-net0

  ovn-nbctl lsp-add net1 net1-r1
  ovn-nbctl lsp-set-addresses net1-r1 52:54:00:c1:68:51
  ovn-nbctl lsp-set-type net1-r1 router
  ovn-nbctl lsp-set-options net1-r1 router-port=r1-net1

}

clean_network() {
 ovs-vsctl del-br br-int
 ovn-nbctl ls-del net0 
 ovn-nbctl ls-del net1
 ovn-nbctl lr-del r1
 CIDR_UUID=$(ovn-nbctl --bare --columns=_uuid find dhcp_options cidr="10.0.0.0/24")
 CIDR_UUID1=$(ovn-nbctl --bare --columns=_uuid find dhcp_options cidr="10.0.1.0/24")
 ovn-nbctl dhcp-options-del $CIDR_UUID
 ovn-nbctl dhcp-options-del $CIDR_UUID1
 ovs-vsctl remove open_vswitch . external_ids ovn-remote
 ovs-vsctl remove open_vswitch . external_ids ovn-encap-type
 ovs-vsctl remove open_vswitch . external_ids ovn-encap-ip

 ovn-sbctl chassis-del slaver01
 ovn-sbctl chassis-del slaver02
 ovn-sbctl chassis-del master

}

if [ "$1" = "set" ]
then
  set_network
elif [ "$1" = "clean" ]
then
  clean_network
else
  echo "invaild argument"
fi
