# Amiga Gentoo Linux image - Amilux
This is a cross compiled HDF image of a stripped down, minimalistic Gentoo install specifically crafted towards Amiga hardwares.

[Download](images)

## How to run under WinUAE
* Download WinUAE + Amiga A3000 3.1 KS ROM image
* [Download](images/amilux.hdf.gz) the HDF image file, and extract it
* [Download](images/amilux.uae) the UAE config file, and correct it's settings for the ROM image + HDF file location
* Have fun!

## Features
* Using MUSL instead of glibc
* Using BusyBox instead of fat Linux userland programs
* Using mdev instead of udev or eudev
* Boot partition is Amiga FFS, containing the kernel and boot loader (amiboot-5.6)
* Linux root is BTRFS, with subvolumes
* No package management installed inside
* No build tools or generally build dependecies inside

## Requirements
* Amiga OCS,ECS,AGA machine
* Motorola 68030 CPU or better with MMU
* At least 10 MByte 32bit FastRAM (in a single block)
* SCSI or IDE HDD with 514MByte space

**What will not work**
* PCI hardware through bus extenders (no implemented driver in kernel)
* BridgeBoards (no implemented driver in kernel)
* X Windows (No DRM driver, Xorg Framebuffer dev can't currently handle bit planar modes)
* No networking in current release yet

## Tested
* WinUAE
* Amiga A4000D + A3660 CPU card + 16MByte RAM + IDE HDD

## Known issues
* ~~Midnight Commander freezes on exit~~
  * ~~workaround: on a different console, kill cons.save subprocess~~
* ~~rc-status SegFaults when displays supervised services~~
* htop shows CPU load incorrectly in graphical manner
* fdisk can't handle Amiga partition table
  * workaround: parted can
* No linux mkfs.affs exists
* shutdown -h halts the kernel, but a few seconds later it Oops'es with stuck process (obvious: no software power down exists)
* kernel uses just a single block of memory, amiboot is outdated, doesn't pass this to it
  * workaround (sort of): you can still use zorro2+chip RAM through /dev/z2ram block device (fe.: to create swap file)

[@world installed packages](documentation/packages.md)
