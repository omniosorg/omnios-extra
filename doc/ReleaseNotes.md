<img src="http://www.omniosce.org/OmniOSce_logo.svg" height="128">

# Release Notes for OmniOSce v11 r151022

[Instructions for updating from OmniTI OmniOS r151022 are available on our web site](http://www.omniosce.org/setup/switch)

## r151022w (2017-10-23)

Weekly release for w/c 23rd of October 2017,
uname -a shows `omnios-r151022-eb9d5cb557` (no change from previous release)
> This is a non-reboot update.

### Security fixes

* `curl` updated to 7.56.1
  * [CVE-2017-1000257](https://curl.haxx.se/docs/adv_20171023.html)

<br>

----

## r151022u (2017-10-09)

Weekly release for w/c 9th of October 2017,
uname -a shows `omnios-r151022-eb9d5cb557` (no change from previous release)
> This is a non-reboot update.

### Security fixes

* `curl` updated to 7.56.0
  * [CVE-2017-1000254](https://www.cvedetails.com/cve/CVE-2017-1000254/)
* `OpenSSH` - sftp-server users with read-only access could create
  zero-length files.
* `sudo` update to 1.8.21p2
  * [CVE-2017-1000368](https://nvd.nist.gov/vuln/detail/CVE-2017-1000368)

### Other changes

* `SUNWcs` partially updated to deliver new `/etc/motd` file matching
  the kernel version. This update was published to the repository last
  week.

<br>

----

## r151022s (2017-09-21)

Early weekly release for w/c 25th of September 2017,
uname -a shows `omnios-r151022-eb9d5cb557`
> This update requires a reboot.

### Security fixes

* Security updates for in-kernel CIFS client & server
  * [8662](https://www.illumos.org/issues/8662) SMB server ioctls should be appropriately sized
  * [8663](https://www.illumos.org/issues/8663) SMB client assumes serialized ioctls
* Perl fixes:
  * [CVE-2017-12837](https://www.cvedetails.com/cve/CVE-2017-12837/)
  * [CVE-2017-12883](https://www.cvedetails.com/cve/CVE-2017-12883/)

### Other changes

* [8651](https://www.illumos.org/issues/8651) loader: fix problem where
  `No rootfs module provided, aborting` could appear on some systems.
* IPsec observability improvements.

Due to the fix to the loader, new release media will be built for this
release.

<br>

----

## r151022r (2017-09-18)

Weekly release for w/c 18th of September 2017, uname -a shows `omnios-r151022-5e982daae6` (no change from previous release)
> This is a non-reboot update.

### Security fixes

* `libxml2` updated to version 2.9.5
* `python` updated to version 2.7.14

### Other changes

* Mozilla NSS updated to version 4.16
* Mozilla NSPR updated to version 3.32.1
* Web CA certificates updated

<br>

----

## r151022q (2017-09-11)

Weekly release for w/c 11th of September 2017, uname -a shows `omnios-r151022-5e982daae6` (no change from previous release)
> This is a non-reboot update.

### Security fixes

* `gnu-binutils` fix for:
  * [CVE-2017-14129](https://www.cvedetails.com/cve/CVE-2017-14129/)

<br>

----

## r151022o (2017-08-28)

Weekly release for w/c 28th of August 2017, uname -a shows `omnios-r151022-5e982daae6` (no change from previous release)
> This is a non-reboot update.

### Security fixes

* `libxml2` fixes for:
  * [CVE-2016-4658](https://www.cvedetails.com/cve/CVE-2016-4658/)
  * [CVE-2016-5131](https://www.cvedetails.com/cve/CVE-2016-5131/)
  * [CVE-2017-0663](https://www.cvedetails.com/cve/CVE-2017-0663/)
  * [CVE-2017-5969](https://www.cvedetails.com/cve/CVE-2017-5969/)
  * [CVE-2017-9047](https://www.cvedetails.com/cve/CVE-2017-9047/)
  * [CVE-2017-9048](https://www.cvedetails.com/cve/CVE-2017-9048/)
  * [CVE-2017-9049](https://www.cvedetails.com/cve/CVE-2017-9049/)
  * [CVE-2017-9050](https://www.cvedetails.com/cve/CVE-2017-9050/)
* `bzip2` fix for:
  * [CVE-2016-3189](https://www.cvedetails.com/cve/CVE-2016-3189/)

### Other changes

* Update `java` to OpenJDK 1.7.0\_141-b02
* Update `/etc/release` to include release version suffix

<br>

----

## r151022m (2017-08-11)

Early weekly release for w/c 14th of August 2017, uname -a shows `omnios-r151022-5e982daae6` (no change from previous release)
> This is a non-reboot update.

### Security fixes

* `git` updated to version 2.13.5
  * CVE-2017-1000117
* `mercurial` updated to version 4.2.3
  * CVE-2017-1000116
  * CVE-2017-1000115

### Other changes

* Update `/etc/release` to include release version suffix

<br>

----

## r151022l (2017-08-07)

Weekly release for w/c 7th of August 2017, uname -a shows `omnios-r151022-5e982daae6` (no change from previous release)
> This release requires a reboot.

### Security fixes

### Bug fixes

* [8395](https://www.illumos.org/issues/8395) mr\_sas: sizeof on array function parameter will return size of pointer
* [8543](https://www.illumos.org/issues/8543) nss\_ldap crashes handling a group with no gidnumber attribute 

### LX zones

* OS-6238 panic in lxpr\_access

### Other changes

* Update `archiver/gnu-tar` manifest to include runtime dependencies
* Update `/etc/release` to include release version suffix

<br>

----  

## r151022k (2017-07-31)

Weekly release for w/c 31st of July 2017, uname -a shows `omnios-r151022-5e982daae6` (no change from previous release)
> This is a non-reboot update.

### Security fixes

* `ncurses` updated to fix:
  * [CVE-2017-10684](https://www.cvedetails.com/cve/CVE-2017-10684/)
  * [CVE-2017-10685](https://www.cvedetails.com/cve/CVE-2017-10685/)
  * [CVE-2017-11112](https://www.cvedetails.com/cve/CVE-2017-11112/)
  * [CVE-2017-11113](https://www.cvedetails.com/cve/CVE-2017-11113/)
* `bind` updated to version 9.10.6

### Other changes

* Update `/etc/release` to include release version suffix and OmniOSce copyright
* Update `/etc/notices/LICENSE` and `/etc/notices/COPYRIGHT` to include OmniOSce copyright

<br>

----  

## r151022i (2017-07-17)

Weekly release for w/c 17th of July 2017, uname -a shows `omnios-r151022-5e982daae6`
> This release requires a reboot.

### Security fixes

* expat updated to version 2.2.2 ([release notes](https://github.com/libexpat/libexpat/blob/R_2_2_2/expat/Changes))

### Bug fixes

* [3167](https://www.illumos.org/issues/3167) kernel panic in apix:apic_timer_init
* [7600](https://www.illumos.org/issues/7600) zfs rollback should pass target snapshot to kernel
* [8055](https://www.illumos.org/issues/8055) mr_sas online-controller-reset (OCR) does not work with some gen3 adapters
* [8303](https://www.illumos.org/issues/8303) loader: biosdisk interface should be able to cope with 4k sectors
* [8377](https://www.illumos.org/issues/8377) Panic in bookmark deletion (ZFS)
* [8378](https://www.illumos.org/issues/8378) crash due to bp in-memory modification of nopwrite block(ZFS)
* [8429](https://www.illumos.org/issues/8429) getallifaddrs dereferences invalid pointer causing SIGSEGV

#### LX zones

* OS-569 svcs -Z should not emit an error message for zones without SMF
* OS-601 svcs -Z in GZ should skip zones in ready state
* OS-1634 svcs -ZL does not work when a pattern is specified
* OS-5028 mount -t nfs4 not working
* OS-6222 lxbrand lseek32 mishandles negative offsets

### Other changes

* Updated loader screen for community edition
* Updated `package/pkg` to display link for OmniOSce release notes
* Added `developer/omnios-build-tools` meta-package

<br>

----  

## r151022h (2017-07-12)

Weekly release for w/c 10th of July 2017, uname -a shows `omnios-r151022-f9693432c2` (no change from previous release)
This is the initial OmniOSce release.

### Security fixes

* expat updated to version 2.2.1 ([CVE-2017-9233](https://libexpat.github.io/doc/cve-2017-9233/))
* curl updated to version 7.54.1 ([CVE-2017-9502](https://curl.haxx.se/docs/adv_20170614.html))
* bind updated to version 9.10.5-P3 ([CVE-2017-3140](https://kb.isc.org/article/AA-01495/0/CVE-2017-3140%3A-An-error-processing-RPZ-rules-can-cause-named-to-loop-endlessly-after-handling-a-query.html))
* p7zip updated ([CVE-2016-9296](https://bugzilla.redhat.com/show_bug.cgi?id=CVE-2016-9296))

### Other updates

* openssl updated to version 1.0.2l
* web/ca-bundle updated to include OmniOSce Certificate Authority certificate

