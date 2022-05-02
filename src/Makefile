LLC ?= llc
CLANG ?= clang
CC ?= gcc

LIBBPF_DIR ?= $(CURDIR)/../libbpf/src
OBJECT_LIBBPF = $(LIBBPF_DIR)/libbpf.a

OUTPUT_DIR ?= $(CURDIR)/.output

CFLAGS ?= -I$(LIBBPF_DIR)/root/usr/include/ -g
LDFLAGS ?= -L$(LIBBPF_DIR)/root/usr/lib64

LIBS = -l:libbpf.a -lelf -lz

all: $(OUTPUT_DIR)/xdp_kern.o $(OUTPUT_DIR)/xdp_stats

$(OUTPUT_DIR):
	mkdir -p $@

$(OBJECT_LIBBPF):
	cd $(LIBBPF_DIR) && mkdir -p build root; \
	BUILD_STATIC_ONLY=y OBJDIR=build DESTDIR=root make install;

$(OUTPUT_DIR)/xdp_kern.o: xdp_kern.c $(OBJECT_LIBBPF) | $(OUTPUT_DIR)
	$(CLANG) -S \
	    -target bpf \
	    -D __BPF_TRACING__ \
	    $(CFLAGS) \
	    -Wall \
	    -Wno-unused-value \
	    -Wno-pointer-sign \
	    -Wno-compare-distinct-pointer-types \
	    -Werror \
	    -O2 -emit-llvm -c -g -o ${@:.o=.ll} $<
	$(LLC) -march=bpf -filetype=obj -o $@ ${@:.o=.ll}

$(OUTPUT_DIR)/xdp_stats: xdp_stats.c $(OBJECT_LIBBPF) | $(OUTPUT_DIR)
	$(CC) -Wall $(CFLAGS) $(LDFLAGS) -o $@ $< $(LIBS)

clean:
	rm -rf $(OUTPUT_DIR)
