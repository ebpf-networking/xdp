#include <linux/bpf.h>
#include <linux/pkt_cls.h>
#include <bpf/bpf_helpers.h>

#include "xdp_common.h"

#ifndef lock_xadd
# define lock_xadd(ptr, val)              \
        ((void)__sync_fetch_and_add(ptr, val))
#endif

#define PIN_GLOBAL_NS		2
struct bpf_elf_map {
	__u32 type;
	__u32 size_key;
	__u32 size_value;
	__u32 max_elem;
	__u32 flags;
	__u32 id;
	__u32 pinning;
};

#define TC_INGRESS_MAP_INDEX    0
#define TC_EGRESS_MAP_INDEX     1


// this map is found at:
// bpftool map dump pinned /sys/fs/bpf/tc/globals/tc_stats_map
struct bpf_elf_map SEC("maps") tc_stats_map = {
	.type = BPF_MAP_TYPE_ARRAY,
	.size_key = sizeof(__u32),
	.size_value = sizeof(__u32),
	.pinning = PIN_GLOBAL_NS,
	.max_elem = 2,
};

static __always_inline int tc_stats_record(struct __sk_buff *skb, __u32 index) {

    __u32 *bytes;

    bytes = bpf_map_lookup_elem(&tc_stats_map, &index);
    if (bytes && skb) {
        lock_xadd(bytes, skb->len);
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
