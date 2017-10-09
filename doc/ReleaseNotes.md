<img src="http://www.omniosce.org/OmniOSce_logo.svg" height="128">

# Release Notes for OmniOSce v11 r151026
![#f03c15](https://placehold.it/15/f03c15/000000?text=+) ** These are DRAFT release notes ** ![#f03c15](https://placehold.it/15/f03c15/000000?text=+)

Stable Release, TBC of May 2018

illumos-omnios branch r151026 at XXX

`uname -a` shows `omnios-r151026-XXX`

r151026 release repository: https://pkg.omniosce.org/r151026/core

## New features since r151024

### System Features

### Hardware Support

### Commands and Command Options

### Developer Features

* GCC version 7 is now available - `pkg install developer/gcc7` - and can be
  found in `/opt/gcc-7`.
  xxx check xxx
  Note that GCC 7's default standard for C++ is `-std=gnu++14`. This is a
  change from GCC 5 which used `-std=gnu++98`. Some software may assume
  gnu++98 and to compile it with GCC 7 you will need to specify
  `--std=gnu++98` or update the software. More detail on the changes in GCC 7
  can be found on
  [the gcc web site](https://gcc.gnu.org/gcc-7/changes.html).

* Perl has been upgraded to 5.26.X. The version of perl shipped with OmniOS
  is for internal system use and should not be relied on for anything else.

### Deprecated features

* GCC version 6 will be removed in the next stable version of OmniOS, r151028.

### Package changes ([+] Added, [-] Removed, [\*] Changed)

XXX

