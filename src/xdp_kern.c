#include <linux/bpf.h>
#include <bpf/bpf_endian.h>
#include <linux/if_ether.h>
#include <linux/ip.h>
#include <bpf/bpf_helpers.h>

#define MAX_STATS_ENTRIES 256

struct datarec {
	__u64	packets;
	__u64	bytes;
};

struct bpf_map_def SEC("maps") xdp_stats_map = {
        .type        = BPF_MAP_TYPE_PERCPU_HASH,
        .key_size    = sizeof(__u32),			// ip
        .value_size  = sizeof(struct datarec),		// counters
        .max_entries = MAX_STATS_ENTRIES,
};

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
                                        __u32 *saddr) {
	struct iphdr *ip = *data;
	if (ip + 1 > data_end)
		return -1;

	*saddr = ip->saddr;
	*data = ip + 1;
	return 0;
}

static __always_inline void xdp_stats_record(struct xdp_md *ctx,
						__u32 saddr) {
	struct datarec *datarec = bpf_map_lookup_elem(&xdp_stats_map, &saddr);
	if (!datarec) {
		struct datarec d;
		d.packets = 1;
		d.bytes = (ctx->data_end - ctx->data);
		bpf_map_update_elem(&xdp_stats_map, &saddr, &d, 0);
		//bpf_printk("%x: packets: %llu bytes: %llu", saddr, d.packets, d.bytes);
		return;
	}
	
	datarec->packets++;
	datarec->bytes += (ctx->data_end - ctx->data);
	//bpf_printk("%x: packets: %llu bytes: %llu", saddr, datarec->packets, datarec->bytes);
	return;
}

SEC("xdp_stats")
int xdp_stats_prog(struct xdp_md *ctx)
{
	void *data = (void *)(long)ctx->data;
	void *data_end = (void *)(long)ctx->data_end;
	__be16 header_type;
	__u32 saddr;

	__u32 action = XDP_PASS;

	header_type = parse_ethhdr(&data, data_end);
	if (header_type != bpf_htons(ETH_P_IP))
		goto out;

	header_type = parse_iphdr(&data, data_end, &saddr);
	if (header_type < 0)
		goto out;

	xdp_stats_record(ctx, saddr);
out:
	return action;
}

char _license[] SEC("license") = "GPL";
