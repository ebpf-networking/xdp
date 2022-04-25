# XDP exploration

## Background

XDP stands for Express Data Path. It is a set of Linux kernel hook points that allow eBPF programs to be invoked. There are 3 supported modes:

1. Hardware offload: eBPF programs are compiled and loaded to NIC hardware
2. Native: eBPF programs are called by the NIC device drivers (before `skb` allocation)
3. Generic: eBPF programs are invoked higher up the stack (after `skb` allocation)

These are in the order of most performant to least performant, where the "general thinking" is `Generic` is only useful for testing and debugging purposes. 

## Objectives

This project is used to explore the capabilities of XDP and its performance characteristics so we have practical experiences with this technology. 
