#!/bin/bash

xdp-loader unload veth-ns1 --all
xdp-loader unload veth-ns2 --all
xdp-loader unload veth-ns3 --all
ip netns del ns1
ip netns del ns2
ip netns del ns3
ip link del br0
rm -rf /sys/fs/bpf/veth-ns*
