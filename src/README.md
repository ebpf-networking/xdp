# Build

```
make
```

# Setup

```
ip netns add ns1
ip link add veth-ns1 type veth peer name veth0 netns ns1
ip netns exec ns1 ip addr add 192.168.100.1/24 dev veth0
ip netns exec ns1 ip link set lo up
ip netns exec ns1 ip link set veth0 up
ip add add 192.168.100.2/24 dev veth-ns1
ip link set veth-ns1 up
```

# Load

```
xdp-loader load -p /sys/fs/bpf/veth-ns1 -s xdp_stats veth-ns1 xdp_kern.o
```

# Test

```
ip netns exec ns1 ping 192.168.100.2
```

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
