#include <linux/bpf.h>
#include <linux/pkt_cls.h>
#include <bpf/bpf_helpers.h>

#include "xdp_common.h"

char LICENSE[] SEC("license") = "Dual BSD/GPL";

#define TC_INGRESS_MAP_INDEX    0
#define TC_EGRESS_MAP_INDEX     1

struct {
    __uint(type, BPF_MAP_TYPE_PERCPU_HASH);
    __uint(max_entries, 2);
    __type(key, __u32);                   // ingress/egress
    __type(value, __u32);                 // bytes
    __uint(pinning, LIBBPF_PIN_BY_NAME);
} tc_stats_map SEC(".maps") ;

static __always_inline int tc_stats_record(struct __sk_buff *skb, __u32 index) {

    __u32 *bytes;

    bytes = bpf_map_lookup_elem(&tc_stats_map, &index);
    if (bytes) {
        bytes += skb->len;
    }
    return TC_ACT_OK;
}

SEC("tc_ingress")
int tc_ingress_stats(struct __sk_buff *skb)
{
    return tc_stats_record(skb, TC_INGRESS_MAP_INDEX);
}

SEC("tc_egress")
int tc_egress_stats(struct __sk_buff *skb)
{
    return tc_stats_record(skb, TC_EGRESS_MAP_INDEX);
}

char _license[] SEC("license") = "GPL";
