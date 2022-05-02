FROM fedora:35

RUN dnf -y update && \
    dnf install -y clang llvm gcc elfutils-libelf-devel glibc-devel.i686 && \
    dnf install -y findutils vim git

RUN cd /tmp && git clone --recurse-submodules https://github.com/ykt-networking/xdp.git

RUN make -C /tmp/xdp/src

