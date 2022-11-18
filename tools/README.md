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

1) Compile one or more kernels to include in the build
1.1) use **m68kmake** inside the kernel dir to cross compile with m68k-unknown-linux-musl-gcc
 # m68kmake menuconfig
 # m68kmake -j12
1.2) OR you can use the qemu-m68k chroot jail to compile kernel semi-natively, as usual
2) **amilux_install**: must be run in qemu-m68k chroot, to install programs + configure root fs, also installs compiled kernels
3) **mk-root.sh**: creates the Linux root filesystem, from a btrfs snapshot
4) **mk-boot.sh**: creates the amiga boot partition
5) **mk-hdf.sh**: combines everything together into a playable HDF image file
6) (optional) **update-docs.sh**: updates the list of installed packages

If you recompile kernel, and just want to rebuild that part, all you need to do is:
1) Compile the kernel
2) **kernel_install**: must be run in qemu-m68k chroot, to install kernel + modules
4) (optional) **mk-root.sh**: if no modules changed, it's not necessary to run
5) **mk-boot.sh**
6) **mk-hdf.sh**
