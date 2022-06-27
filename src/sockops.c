#include <linux/bpf.h>
#include <bpf/bpf_helpers.h>
#include <bpf/bpf_endian.h>

#include "sockops.h"

/*
 * extract the key identifying the socket source of the TCP event
 */
static inline
void sk_extractv4_key(struct bpf_sock_ops *ops,
    struct sock_key *key)
{
    // keep ip and port in network byte order
    key->dip4 = ops->remote_ip4;
    key->sip4 = ops->local_ip4;
    key->family = 1;

    // local_port is in host byte order, and
    // remote_port is in network byte order
    key->sport = (bpf_htonl(ops->local_port) >> 16);
    key->dport = READ_ONCE(ops->remote_port) >> 16;
}

static inline
void bpf_sock_ops_ipv4(struct bpf_sock_ops *skops)
{
    struct sock_key key = {};

    sk_extractv4_key(skops, &key);

    // insert the source socket in the sock_ops_map
    int ret = bpf_sock_hash_update(skops, &sock_ops_map, &key, BPF_NOEXIST);
    bpf_printk("<<< ipv4 op = %d, port %d --> %d\n",
        skops->op, skops->local_port, bpf_ntohl(skops->remote_port));
    if (ret != 0) {
        bpf_printk("FAILED: bpf_sock_hash_update ret: %d\n", ret);
    }
}

SEC("sockops")
int bpf_sockops_v4(struct bpf_sock_ops *skops)
{
    __u32 family, op;

    family = skops->family;
    op = skops->op;

    switch (op) {
        case BPF_SOCK_OPS_PASSIVE_ESTABLISHED_CB:
        case BPF_SOCK_OPS_ACTIVE_ESTABLISHED_CB:
        if (family == 2) { //AF_INET
                        bpf_sock_ops_ipv4(skops);
        }
                break;
        default:
                break;
        }
    return 0;
}

char _license[] SEC("license") = "GPL";
