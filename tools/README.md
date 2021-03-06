# Tools used to cut together the image
First of all, big thanks to [Károly Balogh](https://github.com/chainq/amiga-linux-image) for his amiga-linux-image scripts. I used a lot, and modified heavily.
Also kudos goes to the creator(s) of a python based [amitools](https://github.com/cnvogelg/amitools).

## Dependencies

* [amitools](https://github.com/cnvogelg/amitools) - for `rdbtool` and `xdftool`
* Workbench 3.1 Disk Image ADF
* [amiboot-5.6](https://people.debian.org/~cts/debian-m68k/misc/)
* [GiggleDisk](http://www.geit.de/eng_giggledisk.html)
* [Phase5 CPU support libraries](http://phase5.a1k.org) (optional)
* [FAT95](http://aminet.net/package/disk/misc/fat95)
* various (de)compressors (lha, zip, gzip, xz)
* various standard Unix tools (dd, etc)
* some less standard ones (btrfs-progs)

## The tools

1) **amilux_install**: must be run in qemu-m68k chroot, to install programs + configure root fs
2) **mk-root.sh**: creates the Linux root filesystem, from a btrfs snapshot
3) **mk-boot.sh**: creates the amiga boot partition
4) **mk-hdf.sh**: combines everything together into a playable HDF image file
