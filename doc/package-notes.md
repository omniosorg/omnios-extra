
Originally from Dan McDonald

> From my notes when I finished r151022, here are a list of "STUCK" packages
> and some other didn't-update ones.
> 
> Dan

### binutils

STUCK on 2.25 (vs. 2.26) stupid relocation type 0x2a/42
STT_GNU_IFUNC breaks all sorts of other package builds.
AHA!!! SEE https://www.illumos.org/issues/6653

### cdrtools

STUCK on 3.00 (not worth cost of investigating 3.01)

### glib

STUCK on 2.34.3 (2.50  HAD POSSIBLE PROBLEM...)

### idnkit

NO UPDATE (There is 2.3 available, but it's "idnkit2".)

### ipmitool

BLOCKED, could be 1.8.17 with work...

### isc-dhcp

NO UPDATE (NOTE: ISC now has "Kea" DHCP server replacement)

### open-vm-tools

STUCK on 9.4.0 (really weird stuff...)

### sudo

STUCK on 1.8.7 (Oracle Solaris-isms, among other things)
### swig

STUCK on 2.0.12 (3.0.x breaks M2Crypto, among other things...)

### trousers

STUCK on 0.3.8 (no idea why...)

### python-cherrypy

STUCK on 3.2.2 (breaks IPS on upgrade)

### python-m2crypto

STUCK ON 0.24.0 (0.25.1 update broke IPS pkgsign)

### python-pyopenssl

STUCK ON 0.11 --> never-ending python package pull to update!

### python-setuptools

STUCK ON 0.6.11 (NO IDEA)

