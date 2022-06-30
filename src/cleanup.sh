#!/bin/bash

# Clean up xdp programs
.output/xdp-tools/xdp-loader unload veth-ns1 --all
.output/xdp-tools/xdp-loader unload veth-ns2 --all
.output/xdp-tools/xdp-loader unload veth-ns3 --all
rm -rf /sys/fs/bpf/veth-ns*
rm -rf /sys/fs/bpf/xdp

# Clean up tc programs
.output/iproute2/tc qdisc add dev veth-ns1 clsact
.output/iproute2/tc qdisc add dev veth-ns2 clsact
.output/iproute2/tc qdisc add dev veth-ns2 clsact
.output/xdp-tools/tc filter del dev veth-ns1 ingress
.output/xdp-tools/tc filter del dev veth-ns1 egress
.output/xdp-tools/tc filter del dev veth-ns2 ingress
.output/xdp-tools/tc filter del dev veth-ns2 egress
.output/xdp-tools/tc filter del dev veth-ns3 ingress
.output/xdp-tools/tc filter del dev veth-ns3 egress
rm -rf /sys/fs/bpf/tc
rm -rf /sys/fs/bpf/ip

# Clean up sockops/sockmap
bpftool prog detach pinned "/sys/fs/bpf/bpf_redir" msg_verdict pinned "/sys/fs/bpf/sock_ops_map"
rm -f "/sys/fs/bpf/bpf_redir"
bpftool cgroup detach "/sys/fs/cgroup/" sock_ops pinned "/sys/fs/bpf/sockop"
rm -f "/sys/fs/bpf/sockop"
rm -f "/sys/fs/bpf/sock_ops_map"

# Clean up namespaces
ip netns del ns1
ip netns del ns2
ip netns del ns3
ip link del br0
