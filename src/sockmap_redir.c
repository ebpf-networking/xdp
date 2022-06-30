#include <linux/bpf.h>
#include <bpf/bpf_helpers.h>
#include <bpf/bpf_endian.h>

#include "sockops.h"


/* extract the key that identifies the destination socket in the sock_ops_map */
static inline
void sk_msg_extract4_key(struct sk_msg_md *msg,
	struct sock_key *key)
{
	key->sip4 = msg->remote_ip4;
	key->dip4 = msg->local_ip4;
	key->family = 1;

	key->dport = (bpf_htonl(msg->local_port) >> 16);
	key->sport = READ_ONCE(msg->remote_port) >> 16;
}

SEC("sk_msg")
int bpf_tcpip_bypass(struct sk_msg_md *msg)
{
    struct  sock_key key = {};
    sk_msg_extract4_key(msg, &key);
    bpf_msg_redirect_hash(msg, &sock_ops_map, &key, BPF_F_INGRESS);
    return SK_PASS;
}

char _license[] SEC("license") = "GPL";
