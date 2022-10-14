## TODO

* Evaluate the usage of dev-util/ostree [qmerge] for package install and update
  * Unfortunately it doesn't handle PDEPEND, so installs will be non-functional
* Create a LIVE boot CD, with binary packages
* Add multiple kernel install options
* Add install scripts for a minimal install base
* Option to remove *.h include files (save a few more MBytes)
* Option to install MAN pages as well
* Fix x11-drivers/xf86-video-fbdev to handle planar modes -> enabling Xorg
* ~~Fix distcc on m68k-musl not to segfault after finished working (under qemu)~~
