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

void print_stats(char *ifname) {
    char mapname[PATH_MAX];
    int fd, len, err;
    struct bpf_map_info info = { 0 };
    unsigned int nr_cpus = bpf_num_possible_cpus();
    struct datarec rec[nr_cpus];
   
    /* ipv4 data */ 
    __u32 key = -1, next_key = -1;
    len = snprintf(mapname, PATH_MAX, "%s/%s/%s", pin_basedir, ifname, "xdp_stats_map");
    if (len < 0) {
        fprintf(stderr, "Cannot create map file name\n");
        exit(1);
    }

    fd = open_bpf_map_file(mapname, &info);
    if (!fd)
        return;

    fprintf(stdout, "%s:\n", ifname);
    while (bpf_map_get_next_key(fd, &key, &next_key) == 0) {
        err = bpf_map_lookup_elem(fd, &next_key, &rec);
        if (err == 0) {
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
            fprintf(stdout, "\t[%16s -> %16s]: %lld packets %lld bytes\n", saddr_str, daddr_str, sum.metrics.packets, sum.metrics.bytes);
        }
        key = next_key;
    }
    close(fd);

    /* ipv6 data */ 
    struct in6_addr key_v6, next_key_v6;
    memset(&key_v6, 0, sizeof(key_v6));
    memset(&next_key_v6, 0, sizeof (next_key_v6));
    len = snprintf(mapname, PATH_MAX, "%s/%s/%s", pin_basedir, ifname, "xdp_stats_map_v6");
    if (len < 0) {
        fprintf(stderr, "Cannot create map file name\n");
        exit(1);
    }

    fd = open_bpf_map_file(mapname, &info);
    if (!fd)
        return;

    while (bpf_map_get_next_key(fd, &key_v6, &next_key_v6) == 0) {
        err = bpf_map_lookup_elem(fd, &next_key_v6, &rec);
        if (err == 0) {
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
            fprintf(stdout, "\t[%40s -> %40s]: %lld packets %lld bytes\n", saddr_str, daddr_str, sum.metrics.packets, sum.metrics.bytes);
        }
        memcpy(&key_v6, &next_key_v6, sizeof(struct in6_addr));
    }
    close(fd);
}

void print_all_stats() {
    struct if_nameindex *i, *indices = NULL;
    char ifname[IF_NAMESIZE];

    indices = if_nameindex();
    if (!indices) {
        fprintf(stderr, "Cannot get a list of interfaces\n");
        exit(1);
    }

    for (i = indices; i->if_index; i++) {
        char *ret = if_indextoname(i->if_index, ifname);
        if (!ret) {
            fprintf(stderr, "Cannot find interface name\n");
            exit(1);
        }

        print_stats(ifname);
    }
}

int main(int argc, char** argv) {
    for (;;) {
            system("clear");
        if (argc == 1) {
            print_all_stats();
        }
        else if (argc == 2) {
            print_stats(argv[1]);
        }
        else usage(argv[0]);
        sleep(1);
    }
    exit(0);
}

