#!/bin/bash

.output/xdp-tools/xdp-loader unload veth-ns1 --all
.output/xdp-tools/xdp-loader unload veth-ns2 --all
.output/xdp-tools/xdp-loader unload veth-ns3 --all
.output/iproute2/tc qdisc add dev veth-ns1 clsact
.output/iproute2/tc qdisc add dev veth-ns2 clsact
.output/iproute2/tc qdisc add dev veth-ns2 clsact
.output/xdp-tools/tc filter del dev veth-ns1 ingress
.output/xdp-tools/tc filter del dev veth-ns1 egress
.output/xdp-tools/tc filter del dev veth-ns2 ingress
.output/xdp-tools/tc filter del dev veth-ns2 egress
.output/xdp-tools/tc filter del dev veth-ns3 ingress
.output/xdp-tools/tc filter del dev veth-ns3 egress
ip netns del ns1
ip netns del ns2
ip netns del ns3
ip link del br0
rm -rf /sys/fs/bpf/veth-ns*
rm -rf /sys/fs/bpf/xdp
rm -rf /sys/fs/bpf/tc
rm -f /sys/fs/bpf/ip
