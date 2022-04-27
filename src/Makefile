all: xdp_kern.o xdp_stats

xdp_kern.o: xdp_kern.c
	clang -S -target bpf -D __BPF_TRACING__ -Wall -Wno-unused-value -Wno-pointer-sign -Wno-compare-distinct-pointer-types -Werror -O2 -emit-llvm -c -g -o xdp_kern.ll xdp_kern.c
	llc -march=bpf -filetype=obj -o xdp_kern.o xdp_kern.ll

xdp_stats: xdp_stats.c
	cc -Wall -g -o xdp_stats xdp_stats.c -lbpf -lelf 
clean:
	rm -f *.ll *.o xdp_stats
