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

void print_stats(char *ifname) {
	char mapname[PATH_MAX];
	int fd, len;
	struct bpf_map_info info = { 0 };
	__u64 key = -1, next_key = -1;;
	unsigned int nr_cpus = bpf_num_possible_cpus();
	struct datarec rec[nr_cpus];
	
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
		int err;
		err = bpf_map_lookup_elem(fd, &next_key, &rec);
		if (err < 0) {
			fprintf(stderr, "Map lookup failed on key(%lld)\n", key);
		}
		else {
			int i;
			struct datarec sum = {0};;
			for (i = 0; i < nr_cpus; i++) {
				sum.packets += rec[i].packets;
				sum.bytes += rec[i].bytes;
			}
			struct in_addr saddr = {.s_addr = next_key>>32};
			struct in_addr daddr = {.s_addr = next_key&0xffffffff};
			char *p, saddr_str[16], daddr_str[16];
			p = inet_ntoa(saddr);
			if (p) strncpy(saddr_str, p, 15);
			else break;
			p = inet_ntoa(daddr);
			if (p) strncpy(daddr_str, p, 15);
			else break;
			fprintf(stdout, "\t[%15s -> %15s]: %lld packets %lld bytes\n", saddr_str, daddr_str, sum.packets, sum.bytes);
		}
		key = next_key;
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

