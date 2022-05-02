LLC ?= llc
LLVM_STRIP ?= llvm-strip
CLANG ?= clang
CC ?= gcc

ARCH := $(shell uname -m | sed 's/x86_64/x86/' | sed 's/aarch64/arm64/' | sed 's/ppc64le/powerpc/' | sed 's/mips.*/mips/')

LIBBPF_SRC ?= $(abspath ../libbpf/src)
LIBBPF_OBJECT = $(abspath $(OUTPUT_DIR)/libbpf.a)

OUTPUT_DIR ?= $(CURDIR)/.output

CFLAGS ?= -I$(OUTPUT_DIR)
LDFLAGS ?= -L$(OUTPUT_DIR)

LIBS = -l:libbpf.a -lelf -lz

all: $(OUTPUT_DIR)/xdp_kern.o $(OUTPUT_DIR)/xdp_stats

$(OUTPUT_DIR) $(OUTPUT)/libbpf:
	mkdir -p $@

$(LIBBPF_OBJECT): $(wildcard $(LIBBPF_SRC)/*.[ch] $(LIBBPF_SRC)/Makefile) | $(OUTPUT)/libbpf
	$(MAKE) -C $(LIBBPF_SRC) BUILD_STATIC_ONLY=1 \
	OBJDIR=$(dir $@)/libbpf DESTDIR=$(dir $@) \
	INCLUDEDIR= LIBDIR= UAPIDIR= install

$(OUTPUT_DIR)/xdp_kern.o: xdp_kern.c $(LIBBPF_OBJECT) | $(OUTPUT_DIR)
	$(CLANG) \
	    -g -O2 \
	    -target bpf \
	    -D__TARGET_ARCH_$(ARCH) \
	    $(CFLAGS) \
	    -Wall \
	    -Wno-unused-value \
	    -Wno-pointer-sign \
	    -Wno-compare-distinct-pointer-types \
	    -Werror \
	    -c $< -o $@
	$(LLVM_STRIP) -g $@

$(OUTPUT_DIR)/xdp_stats: xdp_stats.c $(LIBBPF_OBJECT) | $(OUTPUT_DIR)
	$(CC) -Wall -g -O2 $(CFLAGS) $(LDFLAGS) -o $@ $< $(LIBS)

clean:
	rm -rf $(OUTPUT_DIR)
