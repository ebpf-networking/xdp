# Build

```
make
```

# Setup

This creates 3 network namespaces: `ns1`, `ns2`, and `ns3`
```
./testenv.sh
```

# Load

Note: this step is already included in the `testenv.sh`
```
xdp-loader load -p /sys/fs/bpf/veth-ns1 -s xdp_stats veth-ns1 xdp_kern.o
```

# Test

```
ip netns exec ns1 ping 192.168.100.2
```

# Stats

```
.output/xdp_stats veth-ns1
```
or
```
.output/xdp_stats
```

Notice the source IP is always the IP of the veth that we attached our XDP program, no matter what. If we ping from veth-ns2 to veth-ns1 and we are attached to veth-ns1, ICMP requests are getting captured and counted. On the other hand, if we ping from veth-ns1 to veth-ns2, then ICMP replies are getting captured and counted. This is a limitation of XDP, and this example shows it.

# Unload

```
xdp-loader unload veth-ns1 --all
```

# Debug

Enable `bpf_printk()` in the code and recompile.
```
cat /sys/kernel/debug/tracing/trace_pipe
```

Use `bpftool`, i.e.,
```
bpftool map dump id 677
```

# Clean up

```
xdp-loader unload veth-ns1 --all
xdp-loader unload veth-ns2 --all
xdp-loader unload veth-ns3 --all
ip netns del ns1
ip netns del ns2
ip netns del ns3
ip link del br0
rm -rf /sys/fs/bpf/veth-ns*
```
