# Download section
* **amilux.hdf.gz**: Amiga partitioned HDF image file (most probably you need this):
  * 32MiB Amiga FFS boot partition + boot loader + kernel
  * 448MiB Linux BTRFS root partition
  * 32MiB Linux swap partition
* amilux.boot.hdf.xz: Just the boot partition + partition table
* amilux.root.xz: Just the Linux root partition (can be copied to a partition with linux 'dd' command)
* amilux.swap.xz: Empty Linux swap partition
* **amilux.uae**: WinUAE 4.4.0 configuration file, to run the HDF image
