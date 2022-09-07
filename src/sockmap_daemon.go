package main

import (
    "fmt"
    "os"
    "os/exec"
    "io"
    "time"
    "log"
)

func fileCopy(src, dst string) error {
    srcFileStat, err := os.Stat(src)
    if err != nil {
        return err
    }

    if !srcFileStat.Mode().IsRegular() {
        return fmt.Errorf("%s is not a regular file", src)
    }

    source, err := os.Open(src)
    if err != nil {
        return err
    }
    defer source.Close()

    destination, err := os.Create(dst)
    if err != nil {
        return err
    }
    defer destination.Close()

    _, err = io.Copy(destination, source)
    return err
}

func main() {
    fmt.Println("Sockmap daemon process has started...")

    // Copy the required files to host machine
    os.MkdirAll("/opt/sockmap", os.ModePerm)
    fileCopy("/root/bin/bpftool", "/opt/sockmap/bpftool")
    fileCopy("/root/bin/sockmap_redir.o", "/opt/sockmap/sockmap_redir.o")
    fileCopy("/root/bin/sockops.o", "/opt/sockmap/sockops.o")

    // Load and attach ebpf program
    // ./bpftool prog load ./sockops.o "/sys/fs/bpf/sockop"
    // ./bpftool cgroup attach "/sys/fs/cgroup/unified" sock_ops pinned "/sys/fs/bpf/sockop"
    // ./bpftool prog load ./sockmap_redir.o "/sys/fs/bpf/bpf_redir" map name sock_ops_map pinned "/sys/fs/bpf/sock_ops_map"
    // ./bpftool prog attach pinned "/sys/fs/bpf/bpf_redir" msg_verdict pinned "/sys/fs/bpf/sock_ops_map"

    cmd := exec.Command("/opt/sockmap/bpftool", "prog", "load", "/opt/sockmap/sockops.o", "sys/fs/bpf/sockop")
    err := cmd.Run()
    if err != nil {
        log.Fatal(err)
    }

    cmd = exec.Command("/opt/sockmap/bpftool", "cgroup", "attach", "/sys/fs/cgroup/unified", "sock_ops", "pinned", "/sys/fs/bpf/sockop")
    err = cmd.Run()
    if err != nil {
        log.Fatal(err)
    }

    cmd = exec.Command("/opt/sockmap/bpftool", "prog", "load", "/opt/sockmap/sockmap_redir.o", "map", "name", "sock_ops_map", "pinned", "/sys/fs/bpf/sock_ops_map")
    err = cmd.Run()
    if err != nil {
        log.Fatal(err)
    }

    cmd = exec.Command("/opt/sockmap/bpftool", "prog", "attach", "pinned", "/sys/fs/bpf/bpf_redir", "msg_verdict", "pinned", "/sys/fs/bpf/sock_ops_map")
    err = cmd.Run()
    if err != nil {
        log.Fatal(err)
    }

    // TODO: need an API server to load/unload the sockmap program
    for {
        time.Sleep(time.Duration(1<<63 - 1))
    }
}
