/* SPDX-License-Identifier: GPL-2.0 */

#include <bpf/bpf.h>
#include <net/if.h>
#include <arpa/inet.h>

#include "xdp_common.h"

void usage(char *pname) {
	fprintf(stderr, "Usage %s dev_name\n", pname);
	exit(1);
}

int open_bpf_map_file(const char *mapname, struct bpf_map_info *info) {
	int fd, err;
	__u32 info_len = sizeof(*info);

	fd = bpf_obj_get(mapname);
	if (fd < 0) {
		fprintf(stderr, "Cannot open map file %s\n", mapname);
		exit(1);
	}

	if (info) {
		err = bpf_obj_get_info_by_fd(fd, info, &info_len);
		if (err) {
			fprintf(stderr, "Cannot get info, error(%d)\n", errno);
			exit(1);
		}
	}
	return fd;
}

int check_map_fd_info(const struct bpf_map_info *info,
                      const struct bpf_map_info *exp)
{ 
	if (exp->key_size && exp->key_size != info->key_size) {
		fprintf(stderr, "Map key size did not match\n");
		return -1;
	}
	if (exp->value_size && exp->value_size != info->value_size) {
		fprintf(stderr, "Map value size did not match\n");
		return -1;
	}
	if (exp->max_entries && exp->max_entries != info->max_entries) {
		fprintf(stderr, "Map max entries did not match\n");
		return -1;
	}
	if (exp->type && exp->type  != info->type) {
		fprintf(stderr, "Map type did not match\n");
		return -1;
	}
	return 0;
}

void stats_poll(int fd, char* mapname) {
	unsigned int nr_cpus = bpf_num_possible_cpus();
	struct datarec rec[nr_cpus];

	if (!fd) {
		fd = open_bpf_map_file(mapname, 0);
		if (!fd) {
			fprintf(stderr, "Cannot open map file\n");
			exit(1);	
		}
	}

	for (;;) {
		__u64 key = -1, next_key = -1;;
		system("clear");	
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
				char *p, saddr_str[100], daddr_str[100];
				p = inet_ntoa(saddr);
				if (p) strncpy(saddr_str, p, 100);
				else break;
				p = inet_ntoa(daddr);
				if (p) strncpy(daddr_str, p, 100);
				else break;
				fprintf(stdout, "[%15s -> %15s]: %lld packets %lld bytes\n", saddr_str, daddr_str, sum.packets, sum.bytes);
				
			}
			key = next_key;
		}
		sleep(1);
	}
}


int main(int argc, char** argv) {
	const struct bpf_map_info map_expect = {
		.key_size    = sizeof(__u64),
		.value_size  = sizeof(struct datarec),
		.max_entries = MAX_STATS_ENTRIES,
	};
	struct bpf_map_info info = { 0 };
	char mapname[PATH_MAX];
	int stats_map_fd, ifindex, len, err;

	if (argc != 2)
		usage(argv[0]);

	if (strlen(argv[1]) > IF_NAMESIZE) {
		fprintf(stderr, "Device name too long\n");
		exit(1);
	}
	ifindex = if_nametoindex(argv[1]);
	if (ifindex == 0) {
		fprintf(stderr, "Cannot find interface index for %s, error(%d)\n",
			argv[1], errno);
		exit(1);
	}

	len = snprintf(mapname, PATH_MAX, "%s/%s/%s", pin_basedir, argv[1], "xdp_stats_map");
	if (len < 0) {
		fprintf(stderr, "Cannot create map file name\n");
		exit(1);
	}

	for (;;) {
		stats_map_fd = open_bpf_map_file(mapname, &info);
		if (!stats_map_fd)
			exit(1);

		err = check_map_fd_info(&info, &map_expect);
		if (err)
			exit(1);
		
		stats_poll(stats_map_fd, mapname);;
		close(stats_map_fd);
	}
	exit(0);
}

