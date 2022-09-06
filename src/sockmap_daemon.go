package main

import (
    "fmt"
    "os"
    "io"
    "time"
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

    os.MkdirAll("/opt/sockmap", os.ModePerm)
    fileCopy("/root/bin/bpftool", "/opt/sockmap/bpftool")
    fileCopy("/root/bin/sockmap_redir.o", "/opt/sockmap/sockmap_redir.o")
    fileCopy("/root/bin/sockops.o", "/opt/sockmap/sockops.o")
    for {
        time.Sleep(time.Duration(1<<63 - 1))
    }
}
