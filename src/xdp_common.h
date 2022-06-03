#ifndef __XDP_COMMON_H__
#define __XDP_COMMON_H__

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>
#include <linux/ip.h>
#include <linux/ipv6.h>
#include <sys/socket.h>

#define MAX_STATS_ENTRIES 256

struct tc_stats_key {
    __u32 ifindex;
    union {
        __be32 ipv4;
        struct in6_addr ipv6;
    } addr;
};

struct metrics {
    __u64   packets;
    __u64   bytes;
};

struct datarec {
    unsigned short int type;    // AF_INET or AF_INET6

    union {
        __be32 ipv4_addr;
        struct in6_addr ipv6_addr;
    } src;

    union {
        __be32 ipv4_addr;
        struct in6_addr ipv6_addr;
    } dst;

    struct metrics metrics;
};

#ifndef PATH_MAX
#define PATH_MAX    4096
#endif

const char *pin_basedir =  "/sys/fs/bpf";

static inline unsigned int bpf_num_possible_cpus(void)
{
    static const char *fcpu = "/sys/devices/system/cpu/possible";
    unsigned int start, end, possible_cpus = 0;
    char buff[128];
    FILE *fp;
    int n;

    fp = fopen(fcpu, "r");
    if (!fp) {
        printf("Failed to open %s: '%s'!\n", fcpu, strerror(errno));
        exit(1);
    }

    while (fgets(buff, sizeof(buff), fp)) {
        n = sscanf(buff, "%u-%u", &start, &end);
        if (n == 0) {
            printf("Failed to retrieve # possible CPUs!\n");
            exit(1);
        } else if (n == 1) {
            end = start;
        }
        possible_cpus = start == 0 ? end + 1 : 0;
        break;
    }
    fclose(fp);

    return possible_cpus;
}

#endif
