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
* Boot partition is Amiga FFS, containing the kernel and boot loader (amiboot-5.6)
* Linux root is BTRFS, with subvolumes
* No package management installed inside
* No build tools or generally build dependecies inside

## Requirements
* Amiga OCS,ECS,AGA machine
* Motorola 68030 CPU or better with MMU
* At least 10 MByte 32bit FastRAM (in a single block)
* SCSI HDD with 1GByte space

[@world installed packages](documentation/packages.md)
