# Need at least glibc, libelf, libz installed to run xdp-loader, bpftool, and other binaries

# Use a slightly older version of fedora so it's linked to an older version of glibc (v2.29)
FROM fedora:32 AS builder
RUN dnf -y update && \
    dnf install -y clang llvm gcc elfutils-libelf-devel glibc-devel.i686 m4 libpcap-devel make bison flex && \
    dnf install -y findutils vim git
COPY ./ /tmp/xdp
RUN make -C /tmp/xdp/src

FROM frolvlad/alpine-glibc:latest
RUN apk add libelf
RUN mkdir -p /root/bin
COPY --from=builder /tmp/xdp/src/.output/xdp_kern.o /root/bin/
COPY --from=builder /tmp/xdp/src/.output/xdp_stats /root/bin/
COPY --from=builder /tmp/xdp/src/.output/xdp-tools/xdp-loader /root/bin/
COPY --from=builder /tmp/xdp/src/.output/bpftool/bpftool /root/bin/
COPY --from=builder /tmp/xdp/src/.output/tc_kern.o /root/bin/
COPY --from=builder /tmp/xdp/src/.output/iproute2/tc /root/bin/
