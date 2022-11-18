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

* Compile one or more kernels to include in the build
  * use **m68kmake** inside the kernel dir to cross compile with m68k-unknown-linux-musl-gcc
  * OR you can use the qemu-m68k chroot jail to compile kernel semi-natively, as usual
```
# m68kmake menuconfig
# m68kmake -j12
```
* **amilux_install**: must be run in qemu-m68k chroot, to install programs + configure root fs, also installs compiled kernels
* **mk-root.sh**: creates the Linux root filesystem, from a btrfs snapshot
* **mk-boot.sh**: creates the amiga boot partition
* **mk-hdf.sh**: combines everything together into a playable HDF image file
* (optional) **update-docs.sh**: updates the list of installed packages

## If you recompile kernel
Not all of the previously mentioned steps need to be done, just as follows:
* Compile the kernel
* **kernel_install**: must be run in qemu-m68k chroot, to install kernel + modules
* (optional) **mk-root.sh**: if no modules changed, it's not necessary to run
* **mk-boot.sh**
* **mk-hdf.sh**
