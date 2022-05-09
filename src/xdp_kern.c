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
    __type(key, __u32);                   // dst IP
    __type(value, struct datarec);        // data
    __uint(pinning, LIBBPF_PIN_BY_NAME);
} xdp_stats_map SEC(".maps") ;

struct {
    __uint(type, BPF_MAP_TYPE_PERCPU_HASH);
    __uint(max_entries, MAX_STATS_ENTRIES);
    __type(key, struct in6_addr);         // dst IP
    __type(value, struct datarec);        // data
    __uint(pinning, LIBBPF_PIN_BY_NAME);
} xdp_stats_map_v6 SEC(".maps") ;

static __always_inline __be16 parse_ethhdr(void **data,
                    void *data_end) {
    struct ethhdr *eth = *data;

    if (eth + 1 > data_end)
        return 0;

    *data = eth + 1;
    return eth->h_proto;
}

static __always_inline unsigned short int parse_iphdr(void **data,
                    void *data_end,
                    __be16 type,
                    struct datarec *rec) {
    if (type == ETH_P_IP) {
        struct iphdr *ip = *data;
        if (ip + 1 > data_end)
            return -1;

        rec->type = AF_INET;
        rec->src.ipv4_addr = ip->saddr;
        rec->dst.ipv4_addr = ip->daddr;

        *data = ip + 1;
        return rec->type;
    } 
    else if (type == ETH_P_IPV6) {
        struct ipv6hdr *ip = *data;
        if (ip + 1 > data_end)
            return -1;

        rec->type = AF_INET6;
        __builtin_memcpy((void*)&rec->src.ipv6_addr, (void*)&ip->saddr, sizeof(struct in6_addr));
        __builtin_memcpy((void*)&rec->dst.ipv6_addr, (void*)&ip->daddr, sizeof(struct in6_addr));

        *data = ip + 1;
        return rec->type;
    }
    else return 0;
}

static __always_inline void xdp_stats_record(struct xdp_md *ctx,
                        struct datarec *rec) {

    struct datarec *datarec;

    if (rec->type == AF_INET) 
        datarec = bpf_map_lookup_elem(&xdp_stats_map, &rec->dst.ipv4_addr);
    else
        datarec = bpf_map_lookup_elem(&xdp_stats_map_v6, &rec->dst.ipv6_addr);

    if (!datarec) {
        rec->metrics.packets = 1;
        rec->metrics.bytes = (ctx->data_end - ctx->data);
        if (rec->type == AF_INET) 
            bpf_map_update_elem(&xdp_stats_map, &rec->dst.ipv4_addr, rec, 0);
        else
            bpf_map_update_elem(&xdp_stats_map_v6, &rec->dst.ipv6_addr, rec, 0);
        //bpf_printk("%llx: packets: %llu bytes: %llu", addr, d.packets, d.bytes);
        return;
    }
  
    // TODO: Avoid copying the IP addresses each time
    if (rec->type == AF_INET) {
        datarec->src.ipv4_addr = rec->src.ipv4_addr;
        datarec->dst.ipv4_addr = rec->dst.ipv4_addr;
    }
    else { 
        __builtin_memcpy((void*)&datarec->src.ipv6_addr, (void*)&rec->src.ipv6_addr, sizeof(struct in6_addr));
        __builtin_memcpy((void*)&datarec->dst.ipv6_addr, (void*)&rec->dst.ipv6_addr, sizeof(struct in6_addr));
    }
    datarec->metrics.packets++;
    datarec->metrics.bytes += (ctx->data_end - ctx->data);
    //bpf_printk("%llx: packets: %llu bytes: %llu", addr, datarec->packets, datarec->bytes);
    return;
}

SEC("xdp_stats")
int xdp_stats_prog(struct xdp_md *ctx)
{
    void *data = (void *)(long)ctx->data;
    void *data_end = (void *)(long)ctx->data_end;
    __be16 type;
    __u32 action = XDP_PASS;
    struct datarec rec;
    // Ensures padding is initialized
    __builtin_memset(&rec, 0, sizeof(rec)); 

    type = parse_ethhdr(&data, data_end);

    if ((type != bpf_htons(ETH_P_IP)) && (type != bpf_htons(ETH_P_IPV6))) {
        goto out;
    }

    if (parse_iphdr(&data, data_end, bpf_htons(type), &rec) == 0) {
        goto out;
    }

    xdp_stats_record(ctx, &rec);
out:
    return action;
}

char _license[] SEC("license") = "GPL";
