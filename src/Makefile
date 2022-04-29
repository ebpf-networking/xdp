LLC ?= llc
CLANG ?= clang
CC ?= gcc

LIBBPF_DIR ?= ../libbpf/src
OBJECT_LIBBPF = $(LIBBPF_DIR)/libbpf.a

CFLAGS ?= -I$(LIBBPF_DIR)/root/usr/include/ -g
LDFLAGS ?= -L$(LIBBPF_DIR)/root/usr/lib64
BPF_CFLAGS ?= -I$(LIBBPF_DIR)/root/usr/include/

LIBS = -l:libbpf.a -lelf -lz

all: xdp_kern.o xdp_stats

$(OBJECT_LIBBPF):
	cd $(LIBBPF_DIR) && mkdir -p build root; \
	BUILD_STATIC_ONLY=y OBJDIR=build DESTDIR=root make install;

xdp_kern.o: xdp_kern.c
	$(CLANG) -S \
	    -target bpf \
	    -D __BPF_TRACING__ \
	    $(BPF_CFLAGS) \
	    -Wall \
	    -Wno-unused-value \
	    -Wno-pointer-sign \
	    -Wno-compare-distinct-pointer-types \
	    -Werror \
	    -O2 -emit-llvm -c -g -o ${@:.o=.ll} $<
	$(LLC) -march=bpf -filetype=obj -o $@ ${@:.o=.ll}

xdp_stats: xdp_stats.c $(OBJECT_LIBBPF)
	$(CC) -Wall $(CFLAGS) $(LDFLAGS) -o $@ $< $(LIBS)

clean:
	rm -f *.ll *.o xdp_stats
