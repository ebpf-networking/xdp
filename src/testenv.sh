#!/bin/sh

set -e

# This script creates 3 netns. For each netns, it creates a veth pair.
# The end of each veth pair is connected to a Linux bridge.

##################################################
#
# These steps create a basic Linux networking 
# environment using namespaces, veth, bridge
#
##################################################

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
ip netns exec ns1 ip addr add fc00:dead:cafe:1::1/64 dev veth0
ip netns exec ns1 ip link set lo up
ip netns exec ns1 ip link set veth0 up
ip link set veth-ns1 up
ip netns exec ns2 ip addr add 192.168.100.2/24 dev veth0
ip netns exec ns2 ip addr add fc00:dead:cafe:1::2/64 dev veth0
ip netns exec ns2 ip link set lo up
ip netns exec ns2 ip link set veth0 up
ip link set veth-ns2 up
ip netns exec ns3 ip addr add 192.168.100.3/24 dev veth0
ip netns exec ns3 ip addr add fc00:dead:cafe:1::3/64 dev veth0
ip netns exec ns3 ip link set lo up
ip netns exec ns3 ip link set veth0 up
ip link set veth-ns3 up

# create a linux bridge and connect the veths
ip link add br0 type bridge
ip link set veth-ns1 master br0
ip link set veth-ns2 master br0
ip link set veth-ns3 master br0
ip link set br0 up

##################################################
#
# Loading xdp program with xdp-loader
# These steps can be enabled/disabled as needed
#
##################################################

# note: add '-vv' if xdp-loader fails due to verifier to get more debugging hints
#xdp-loader load -p /sys/fs/bpf/veth-ns1 -s xdp_stats veth-ns1 .output/xdp_kern.o
#xdp-loader load -p /sys/fs/bpf/veth-ns2 -s xdp_stats veth-ns2 .output/xdp_kern.o
#xdp-loader load -p /sys/fs/bpf/veth-ns3 -s xdp_stats veth-ns3 .output/xdp_kern.o

##################################################
#
# Loading tc program with tc command
# These steps can be enabled/disabled as needed
#
##################################################

#.output/iproute2/tc qdisc add dev veth-ns1 clsact
#.output/iproute2/tc filter add dev veth-ns1 ingress bpf da obj .output/tc_kern.o sec tc_ingress
#.output/iproute2/tc filter add dev veth-ns1 egress bpf da obj .output/tc_kern.o sec tc_egress

#.output/iproute2/tc qdisc add dev veth-ns2 clsact
#.output/iproute2/tc filter add dev veth-ns2 ingress bpf da obj .output/tc_kern.o sec tc_ingress
#.output/iproute2/tc filter add dev veth-ns2 egress bpf da obj .output/tc_kern.o sec tc_egress

#.output/iproute2/tc qdisc add dev veth-ns3 clsact
#.output/iproute2/tc filter add dev veth-ns3 ingress bpf da obj .output/tc_kern.o sec tc_ingress
#.output/iproute2/tc filter add dev veth-ns3 egress bpf da obj .output/tc_kern.o sec tc_egress

#.output/iproute2/tc filter show dev veth-ns1 ingress
#.output/iproute2/tc filter show dev veth-ns1 egress

##################################################
#
# Loading sockops/sockmap program using bpftool
# These steps can be enabled/disabled as needed
#
##################################################

# load and attach sockops program 
bpftool prog load .output/sockops.o "/sys/fs/bpf/sockop"
bpftool cgroup attach "/sys/fs/cgroup/" sock_ops pinned "/sys/fs/bpf/sockop"

# pin sock_ops_map to a designated place
#MAP_ID=$(sudo bpftool prog show pinned "/sys/fs/bpf/sockop" | grep -o -E 'map_ids [0-9]+' | awk '{print $2}')
#bpftool map pin id $MAP_ID "/sys/fs/bpf/sock_ops_map"

bpftool prog load .output/sockmap_redir.o "/sys/fs/bpf/bpf_redir" map name sock_ops_map pinned "/sys/fs/bpf/sock_ops_map"
bpftool prog attach pinned "/sys/fs/bpf/bpf_redir" msg_verdict pinned "/sys/fs/bpf/sock_ops_map"

# test connectivity
nsenter --net=/var/run/netns/ns2 ping -c 1 192.168.100.1
nsenter --net=/var/run/netns/ns3 ping -c 1 192.168.100.1
