<img src="http://www.omniosce.org/OmniOSce_logo.svg" height="128">

# Release Notes for OmniOSce v11 r151024
![#f03c15](https://placehold.it/15/f03c15/000000?text=+) ** These are DRAFT release notes ** ![#f03c15](https://placehold.it/15/f03c15/000000?text=+)

Stable Release, TBC of November 2017

illumos-omnios branch r151024 at XXX

`uname -a` shows `omnios-r151024-XXX`

r151024 release repository: https://pkg.omniosce.org/r151024/core

## New features since r151022

### System Features

* Support for SuSE linux images within lx zones, courtesy of Joyent.

* Loader can now handle disks with native 4k sectors.

* `svcs -Z` no longer emits an error message for zones which do not have SMF.

* The GCC C++ compiler now supports `__cxa_atexit` which is required for
  fully standards-compliant handling of static destructors.

* Java is now an optional package, only required if you use the dynamic
  resource pools feature. After upgrade to r151024, you can remove java
  if desired as follows:

  `omnios# pkg uninstall runtime/java java/jdk service/resource-pools/poold`

* The `openssl` package now contains both OpenSSL 1.0.2 and 1.1.0, managed
  by a versioned variant. This is the first step on the two year plan to
  upgrade to OpenSSL 1.1 before the end-of-life date for 1.0. Note that
  OmniOS itself does not yet build with OpenSSL 1.1. For more information
  and a list of affected parts of OmniOS, see the
  [repository README file](https://github.com/omniosorg/omnios-build/tree/master/build/openssl)

* The `package/pkg/depot`, `package/pkg/system-repository` and
  `package/pkg/zones-proxy` packages have been removed from OmniOS.
  The first two were not previously installable without work and the
  latter could only be installed in a non-global zone, where it did no good
  without the corresponding part in the global zone.
  `package/pkg/zones-proxy` has been marked as obsolete so will be
  automatically removed from non-global zones as they are upgraded.

* `pkg/server` can now serve repositories for publisher names containing
  a hyphen.

* `mountd` and `statd` can now be run on a fixed port.

### Hardware Support

* Support for AVX-512 processor extensions.

* Support for Chelsio T6 Ethernet devices.

* The `audiovia97` driver has been removed.

### Commands and Command Options

* `zpool scrub -p` to pause a scrub.

* New `nvmeadm` utility to manage NVMe controllers and namespaces.

* New `zfs program` facility to run lua scripts to perform batch
  administrative ZFS operations.
  See [Issue 7431](https://www.illumos.org/issues/7431) for more details,
  man page and examples.

* `xargs` has a new option `-P <maxprocs>` to run up to *maxprocs* parallel
  child processes.

* `last` has a new option `-l` to show longer dates and times, including
  the current year.

### Developer Features

* GCC has been upgraded to 5.4.0 and **moved to `/opt/gcc-5`** to reflect the
  new numbering scheme used from version 5 onwards. The mediated symlinks in
  /usr/bin are still the best way to invoke GCC but you may need to update
  your `$PATH` or scripts if you have previously explicitly used
  `/opt/gcc-5.1.0`.

* Perl has been upgraded to 5.24.2 and the components have been renamed to
  remove the minor version from paths. This means that modules no longer
  have to be rebuilt/moved following minor perl upgrades. The version of perl
  shipped with OmniOS is for internal system use and should not be relied on
  for anything else.

* All of the constraints delivered under `incorporation/jeos/omnios-userland`
  are now protected with `version-lock` facets. This allows each constraint
  to be selectively disabled. This is most useful for people developing
  OmniOS but can also aid temporary local package updates. Example:

  `omnios# pkg change-facet version-lock.web/wget=False`

* New `omnios-build-tools` package to easily install everything required to
  build OmniOS userland.

* It is now possible to build OmniOS in a non-global zone (with the caveat
  that it is not possible to build release media in a NGZ).

### Deprecated features

* The `calendar` utility has been removed.
* The `audiovia97` driver has been removed.

### Package changes ([+] Added, [-] Removed, [\*] Changed)

XXX

