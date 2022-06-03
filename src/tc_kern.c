#include <linux/bpf.h>
#include <linux/pkt_cls.h>
#include <bpf/bpf_helpers.h>
#include <bpf/bpf_endian.h>
#include <linux/if_ether.h>
#include <linux/ip.h>

#include "xdp_common.h"

struct tc_stats_key {
    __u32 ifindex;
    union {
        __be32 ipv4;
        struct in6_addr ipv6;
    } addr;
};

// Make sure to use the tc binary linked with libbpf for btf map
// This map is pinned to /sys/fs/bpf/tc/globals
struct {
    __uint(type, BPF_MAP_TYPE_PERCPU_HASH);
    __uint(max_entries, MAX_STATS_ENTRIES);
    __type(key, struct tc_stats_key);
    __type(value, struct datarec);
    __uint(pinning, LIBBPF_PIN_BY_NAME);
} tc_ingress_stats_map SEC(".maps");

struct {
    __uint(type, BPF_MAP_TYPE_PERCPU_HASH);
    __uint(max_entries, MAX_STATS_ENTRIES);
    __type(key, struct tc_stats_key);
    __type(value, struct datarec);
    __uint(pinning, LIBBPF_PIN_BY_NAME);
} tc_egress_stats_map SEC(".maps");

static __always_inline int tc_stats_record(struct __sk_buff *skb, void* map) {

    struct tc_stats_key key;
    struct datarec *datarec, rec;
    void *data = (void*)(long)skb->data;
    void *data_end = (void*)(long)skb->data_end;
    struct ethhdr *eth = data;

    if (data + sizeof(*eth) > data_end)
            return TC_ACT_OK;
    data = eth + 1;

    __builtin_memset(&rec, 0, sizeof(rec));
    __builtin_memset(&key, 0, sizeof(key));
    key.ifindex = skb->ifindex;

    if (eth->h_proto == bpf_htons(ETH_P_IP)) {
        struct iphdr *ip = data;
        if (ip + 1 > data_end)
            return TC_ACT_OK;

        if (map == &tc_ingress_stats_map) {
            key.addr.ipv4 = ip->daddr;
        }
        else {
            key.addr.ipv4 = ip->saddr;
        }

        rec.type = AF_INET;
        rec.src.ipv4_addr = ip->saddr;
        rec.dst.ipv4_addr = ip->daddr;
    }
    else if (eth->h_proto == bpf_htons(ETH_P_IPV6)) {
        struct ipv6hdr *ip = data;
        if (ip + 1 > data_end)
            return TC_ACT_OK;

        if (map == &tc_ingress_stats_map) {
            __builtin_memcpy((void*)&key.addr.ipv6, (void*)&ip->daddr, sizeof(struct in6_addr));
        }
        else {
            __builtin_memcpy((void*)&key.addr.ipv6, (void*)&ip->saddr, sizeof(struct in6_addr));
        }

        rec.type = AF_INET6;
        __builtin_memcpy((void*)&rec.src.ipv6_addr, (void*)&ip->saddr, sizeof(struct in6_addr));
        __builtin_memcpy((void*)&rec.dst.ipv6_addr, (void*)&ip->daddr, sizeof(struct in6_addr));
    }
    else return TC_ACT_OK;

    datarec = bpf_map_lookup_elem(map, &key);
    if (!datarec) {
        rec.metrics.packets = 1;
        rec.metrics.bytes = (skb->data_end - skb->data);
        bpf_map_update_elem(map, &key, &rec, 0);
    }
    else {
        if (rec.type == AF_INET) {
            datarec->src.ipv4_addr = rec.src.ipv4_addr;
            datarec->dst.ipv4_addr = rec.dst.ipv4_addr;
        }
        else {
            __builtin_memcpy((void*)&datarec->src.ipv6_addr, (void*)&rec.src.ipv6_addr, sizeof(struct in6_addr));
            __builtin_memcpy((void*)&datarec->dst.ipv6_addr, (void*)&rec.dst.ipv6_addr, sizeof(struct in6_addr));
        }
        datarec->metrics.packets++;
        datarec->metrics.bytes += (skb->data_end - skb->data);
    }
    return TC_ACT_OK;
}

SEC("tc_ingress")
int tc_ingress_stats(struct __sk_buff *skb)
{
    return tc_stats_record(skb, &tc_ingress_stats_map);
}

SEC("tc_egress")
int tc_egress_stats(struct __sk_buff *skb)
{
    return tc_stats_record(skb, &tc_egress_stats_map);
}

char _license[] SEC("license") = "GPL";
