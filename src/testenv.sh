#!/bin/sh

# create netns
ip netns add ns1
ip netns add ns2
ip netns add ns3

# create veth pairs
ip link add veth-ns1 type veth peer name veth0 netns ns1
ip link add veth-ns2 type veth peer name veth0 netns ns2
ip link add veth-ns3 type veth peer name veth0 netns ns3

# bring up the veths
ip netns exec ns1 ip addr add 192.168.100.1/24 dev veth0
ip netns exec ns1 ip link set lo up
ip netns exec ns1 ip link set veth0 up
ip link set veth-ns1 up
ip netns exec ns2 ip addr add 192.168.100.2/24 dev veth0
ip netns exec ns2 ip link set lo up
ip netns exec ns2 ip link set veth0 up
ip link set veth-ns2 up
ip netns exec ns3 ip addr add 192.168.100.3/24 dev veth0
ip netns exec ns3 ip link set lo up
ip netns exec ns3 ip link set veth0 up
ip link set veth-ns3 up

# create a linux bridge and connect the veths
ip link add br0 type bridge
ip link set veth-ns1 master br0
ip link set veth-ns2 master br0
ip link set veth-ns3 master br0
ip link set br0 up

# test connectivity
nsenter --net=/var/run/netns/ns2 ping -c 1 192.168.100.1
nsenter --net=/var/run/netns/ns3 ping -c 1 192.168.100.1

