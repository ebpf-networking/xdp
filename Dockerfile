# Need at least glibc, libelf, libz installed to run xdp-loader, bpftool, and other binaries

FROM fedora:35 AS builder
RUN dnf -y update && \
    dnf install -y clang llvm gcc elfutils-libelf-devel glibc-devel.i686 m4 libpcap-devel && \
    dnf install -y findutils vim git
COPY ./ /tmp/xdp
RUN make -C /tmp/xdp/src

FROM alpine:latest
RUN mkdir -p /root/bin
COPY --from=builder /tmp/xdp/src/.output/xdp_kern.o /root/bin/
COPY --from=builder /tmp/xdp/src/.output/xdp_stats /root/bin/
COPY --from=builder /tmp/xdp/src/.output/xdp-tools/xdp-loader /root/bin/
COPY --from=builder /tmp/xdp/src/.output/bpftool/bpftool /root/bin/
