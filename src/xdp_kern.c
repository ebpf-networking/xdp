#include <linux/bpf.h>
#include <bpf/bpf_endian.h>
#include <linux/if_ether.h>
#include <linux/ip.h>
#include <bpf/bpf_helpers.h>

#include "xdp_common.h"

char LICENSE[] SEC("license") = "Dual BSD/GPL";

struct {
	__uint(type, BPF_MAP_TYPE_PERCPU_HASH);
	__uint(max_entries, MAX_STATS_ENTRIES);
	__type(key, __u64);			// src:ip+dst:ip
	__type(value, struct datarec);		// counters
        __uint(pinning, LIBBPF_PIN_BY_NAME);
} xdp_stats_map SEC(".maps") ;

static __always_inline int parse_ethhdr(void **data,
					void *data_end) {
	struct ethhdr *eth = *data;
	__be16 header_type;

	if (eth + 1 > data_end)
		return -1;

	header_type = eth->h_proto;
	*data = eth + 1;
	return header_type;
}

static __always_inline int parse_iphdr(void **data,
					void *data_end,
					__u64 *addr) {
	struct iphdr *ip = *data;
	if (ip + 1 > data_end)
		return -1;

	*addr = ((long long)ip->saddr<<32)+ip->daddr;
	*data = ip + 1;
	return 0;
}

static __always_inline void xdp_stats_record(struct xdp_md *ctx,
						__u64 addr) {
	struct datarec *datarec = bpf_map_lookup_elem(&xdp_stats_map, &addr);
	if (!datarec) {
		struct datarec d;
		d.packets = 1;
		d.bytes = (ctx->data_end - ctx->data);
		bpf_map_update_elem(&xdp_stats_map, &addr, &d, 0);
		//bpf_printk("%llx: packets: %llu bytes: %llu", addr, d.packets, d.bytes);
		return;
	}
	
	datarec->packets++;
	datarec->bytes += (ctx->data_end - ctx->data);
	//bpf_printk("%llx: packets: %llu bytes: %llu", addr, datarec->packets, datarec->bytes);
	return;
}

SEC("xdp_stats")
int xdp_stats_prog(struct xdp_md *ctx)
{
	void *data = (void *)(long)ctx->data;
	void *data_end = (void *)(long)ctx->data_end;
	__be16 header_type;
	__u64 addr;

	__u32 action = XDP_PASS;

	header_type = parse_ethhdr(&data, data_end);
	if (header_type != bpf_htons(ETH_P_IP))
		goto out;

	header_type = parse_iphdr(&data, data_end, &addr);
	if (header_type < 0)
		goto out;

	xdp_stats_record(ctx, addr);
out:
	return action;
}

char _license[] SEC("license") = "GPL";
