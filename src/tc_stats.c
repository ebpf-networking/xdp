/* SPDX-License-Identifier: GPL-2.0 */

#include <bpf/bpf.h>
#include <net/if.h>
#include <arpa/inet.h>

#include "xdp_common.h"

void usage(char *pname) {
    fprintf(stderr, "Usage %s [dev_name]\n", pname);
    exit(1);
}

int open_bpf_map_file(const char *mapname, struct bpf_map_info *info) {
    int fd, err;
    __u32 info_len = sizeof(*info);

    fd = bpf_obj_get(mapname);
    if (fd < 0)
        return 0;

    if (info) {
        err = bpf_obj_get_info_by_fd(fd, info, &info_len);
        if (err) {
            fprintf(stderr, "Cannot get info, error(%d)\n", errno);
            exit(1);
        }
    }
    return fd;
}

bool ipv6_is_empty(struct in6_addr *ip) {
    int i;
    for (i = 0; i < 16; i++) {
        if (ip->s6_addr[i] != 0)
            return false;
    }
    return true;
}

// if ifname==NULL, print all interfaces
void print_stats(char *ifname, char *map_name) {
    char mapname[PATH_MAX];
    int fd, len, err;
    struct bpf_map_info info = { 0 };
    unsigned int nr_cpus = bpf_num_possible_cpus();
    struct datarec rec[nr_cpus];
    struct tc_stats_key key, next_key;
    memset(&key, 0, sizeof(key));
    memset(&next_key, 0, sizeof (next_key));

    len = snprintf(mapname, PATH_MAX, "%s/%s/%s", pin_basedir, "tc/globals", map_name);
    if (len < 0) {
        fprintf(stderr, "Cannot create map file name\n");
        exit(1);
    }
    
    fd = open_bpf_map_file(mapname, &info);
    if (!fd)
        return;

    fprintf(stdout, "%s\n", map_name);
    while (bpf_map_get_next_key(fd, &key, &next_key) == 0) {
        err = bpf_map_lookup_elem(fd, &next_key, &rec);
        if (err == 0) {

            if (rec[0].type == AF_INET) {
                int i;
                struct datarec sum = {0};
                struct in_addr saddr = { 0 };
                struct in_addr daddr = { 0 };
                bool found_ip = false;
                for (i = 0; i < nr_cpus; i++) {
                    sum.metrics.packets += rec[i].metrics.packets;
                    sum.metrics.bytes += rec[i].metrics.bytes;
                    if (!found_ip) {
                        if (rec[i].src.ipv4_addr != 0) {
                            saddr.s_addr = rec[i].src.ipv4_addr;
                            daddr.s_addr = rec[i].dst.ipv4_addr;
                            found_ip = true;
                        }
                    }
                }
                char *p, saddr_str[INET_ADDRSTRLEN], daddr_str[INET_ADDRSTRLEN];
                p = inet_ntoa(saddr);
                if (p)
                    strncpy(saddr_str, p, INET_ADDRSTRLEN-1);
                else
                    return;
                p = inet_ntoa(daddr);
                if (p)
                    strncpy(daddr_str, p, INET_ADDRSTRLEN-1);
                else
                    return;
                if (found_ip)
                    fprintf(stdout, "\t[%16s -> %16s]: %lld packets %lld bytes\n", saddr_str, daddr_str, sum.metrics.packets, sum.metrics.bytes);
            }
            else if (rec[0].type == AF_INET6) {
                int i;
                struct datarec sum = { 0 };
                struct in6_addr saddr = { 0 };
                struct in6_addr daddr = { 0 };
                bool found_ip = false;
                for (i = 0; i < nr_cpus; i++) {
                    sum.metrics.packets += rec[i].metrics.packets;
                    sum.metrics.bytes += rec[i].metrics.bytes;
                    if (!found_ip) {
                        if (!ipv6_is_empty(&rec[i].src.ipv6_addr)) {
                            memcpy(saddr.s6_addr, &rec[0].src.ipv6_addr, sizeof(struct in6_addr));
                            memcpy(daddr.s6_addr, &rec[0].dst.ipv6_addr, sizeof(struct in6_addr));
                            found_ip = true;
                        }
                    }
                }
                char *p, saddr_str[INET6_ADDRSTRLEN], daddr_str[INET6_ADDRSTRLEN];
                p = (char*)inet_ntop(AF_INET6, &saddr, saddr_str, INET6_ADDRSTRLEN);
                if (p)
                    strncpy(saddr_str, p, INET6_ADDRSTRLEN-1);
                else
                    return;
                p = (char*)inet_ntop(AF_INET6, &daddr, daddr_str, INET6_ADDRSTRLEN);
                if (p)
                    strncpy(daddr_str, p, INET6_ADDRSTRLEN-1);
                else
                    return;
                if (found_ip)
                    fprintf(stdout, "\t[%40s -> %40s]: %lld packets %lld bytes\n", saddr_str, daddr_str, sum.metrics.packets, sum.metrics.bytes);
            }
            else {
                fprintf(stdout, "\t ***** garbage data\n");
            }
        }
        memcpy(&key, &next_key, sizeof(struct tc_stats_key));
    }
    close(fd);
}

int main(int argc, char** argv) {
    for (;;) {
            system("clear");
        if (argc == 1) {
            print_stats(NULL, "tc_ingress_stats_map");
            print_stats(NULL, "tc_egress_stats_map");
        }
        else usage(argv[0]);
        sleep(1);
    }
    exit(0);
}

