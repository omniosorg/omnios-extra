<img src="http://www.omniosce.org/OmniOSce_logo.svg" height="128">

# Release Notes for OmniOSce v11 r151022

[instructions for updating from OmniTI OmniOS r151022 to the community edition can be found below](#upgrading-from-omniti-released-r151022)

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

<br>

----  

### Upgrading from OmniTI-released r151022

All OmniOS packages are signed and the pkg installer is configured to only
allow trusted sources for the core packages. In order to upgrade to the new
OmniOS community edition, you have to let your box know that the updates will
be coming from a new trusted source. This means you will have to import our CA
certificate into your system.

Get a copy of the new certificate
```
# /usr/bin/wget -P /etc/ssl/pkg https://downloads.omniosce.org/ssl/omniosce-ca.cert.pem 
```
Check the certificate fingerprint
```
# /usr/bin/openssl x509 -fingerprint  -in /etc/ssl/pkg/omniosce-ca.cert.pem -noout 
8D:CD:F9:D0:76:CD:AF:C1:62:AF:89:51:AF:8A:0E:35:24:4C:66:6D
```

Change the publisher to our new repository:

```
# /usr/bin/pkg set-publisher -P \
  -G https://pkg.omniti.com/omnios/r151022/ \
  -g https://pkg.omniosce.org/r151022/core/ omnios 
```

For each native zone (if you have any), run

```
# /usr/bin/pkg -R <zone_root> set-publisher -P \
   -G https://pkg.omniti.com/omnios/r151022/ \
   -g https://pkg.omniosce.org/r151022/core/ omnios 
```
> (get a list of all your zones by running zoneadm list -cv for the
> <zone_root>, add /root to the PATH given in the list.)

Install the new ca-bundle containing our new CA
```
# /usr/bin/pkg update -rv web/ca-bundle 
```
Remove the CA file imported by hand
```
# rm /etc/ssl/pkg/omniosce-ca.cert.pem 
```
Finally update as usual
```
# /usr/bin/pkg update -rv 
```

