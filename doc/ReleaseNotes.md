<a href="https://omniosce.org">
<img src="https://omniosce.org/OmniOSce_logo.svg" height="128">
</a>

# Release Notes for OmniOSce v11 r151026
![#f03c15](https://placehold.it/15/f03c15/000000?text=+) ** These are DRAFT release notes ** ![#f03c15](https://placehold.it/15/f03c15/000000?text=+)

Stable Release, TBC of May 2018

`uname -a` shows `omnios-r151026-XXX`

r151026 release repository: https://pkg.omniosce.org/r151026/core

## New features since r151024

### System Features

* Experimental support for `bhyve` virtual machines. See
  [https://omniosce.org/info/bhyve](https://omniosce.org/info/bhyve)
  for details.

* Support for `sparse` branded zones. This is a linked-ipkg
  zone that shares most of the `/usr`, `/sbin` and `/lib` directories with
  the global zone. Sparse zones are tiny (under 4MiB of installed
  files) and perfect for isolating small services or VM instances for extra
  security or to apply more granular resource controls.

* The ISO/USB installer has received multiple updates. It is now half the
  size and around seven times faster to start up, text menus have been
  replaced with dialogues to make it easier to navigate, and it is now
  possible to select DHCP assignment of the DNS parameters. Additional
  options are available for configuring aspects of the root pool including
  whether to force a 4K block size (ashift=12) and whether to use use
  EFI or MBR labels.

* The default mail submission agent is now `Dragonfly Mail Agent (dma)` rather
  than sendmail. In a default installation, `/usr/lib/sendmail` points to
  `dma` and can deliver email messages to local users and Internet recipients.
  Dragonfly supports TLS and SMTP authentication out of the box - see
  `/etc/dma/dma.conf` and `man dma` for available options.
  There are now three mediated MTA/MSA packages in OmniOS, `dma`, `sendmail`
  and `mailwrapper`; only `dma` is installed by default. To switch between
  them, install the appropriate package and then configure the `mta` mediator
  implementation, for example:
    ```
	# pkg install service/network/smtp/sendmail

	# pkg mediator -a mta
	MEDIATOR VER. SRC. VERSION IMPL. SRC. IMPLEMENTATION
	mta      system            system     mailwrapper
	mta      system            system     sendmail
	mta      vendor            vendor     dma

	# pkg set-mediator -I sendmail mta
    ```

  Note that `dma` does not support more advanced features such as `.forward`
  files in home directories. If you need these features you should switch back
  to `sendmail` as shown above.

  Mailwrapper is still available to support use of packages from non-IPS
  repositories such as _pkgsrc_ via `/etc/mailer.conf`

* A new `service/network/ntpsec` package is available as an alternative to
  `service/network/ntp`. NTPsec is a secure, hardened and improved
  implementation of the Network Time Protocol derived from NTP Classic.
  NTPsec also runs with stack protection and ASLR out of the box on OmniOS.
  To switch just record any changes you have made to `/etc/inet/ntp.conf` and
  the service manifest properties (`svcprop -p config ntp`) and then
  `pkg uninstall service/network/ntp && pkg install service/network/ntpsec`.
  Restore any customisations and then start the network/ntp service.

* A number of system components now enable Address Space Layout Randomisation
  (ASLR) by default:
    * OpenSSH daemon
    * pfexecd
    * rpcbind
    * Sendmail
    * Dragonfly Mail Agent
    * NTP & NTPsec
    * DHCP daemon
    * SNMP daemon

* `openssh` has been upgraded to 7.6p1. This version drops support for
  SSH protocol version 1, RSA keys under 1024 bits in length and a number
  of old ciphers and MACs. Refer to
  [the release notes](https://www.openssh.com/txt/release-7.6) for more
  details.
  Several legacy SunSSH compatibility options for OpenSSH are deprecated
  and will be removed in a future release; see below for more details.

* `libdiskmgt` (and therefore `diskinfo`) now recognises nvme, sata and xen
  controllers.

* It is now possible to boot OmniOS from a root pool which uses RAIDZ2 or
  RAIDZ3.

* The `/etc/screenrc` file delivered by the `screen` package is now based on
  the recommended global template as delivered by the authors; you may wish
  to check that it still meets your needs. If you have previously customised
  this file then it will not be updated but the new template file will be
  installed as `/etc/screenrc.new`.

* `screen` is now linked against ncurses in order to support more terminal
  types (e.g. iterm)

* New fault management (FMA) event for an SSD that is nearing its end-of-life
  as projected by the manufacturer (SSD wearout, see
  [illumos Issue 8074](https://www.illumos.org/issues/8074))

* Many improvements in resource management within zones.

* IPv6 default address selection table updated for RFC6724.

* Improvements to page recovery under low memory conditions.

* Workarounds for some systems with known broken firmware.

### Package Management

* A new `pkg apply-hot-fix` command has been added to make it easier to apply
  a hot-fix directly from a package archive. For example:
    ```
	% pfexec pkg apply-hot-fix --be-name=hotfix1234 https://downloads.omniosce.org/pkg/r151022/1234_hotfix.p5p
    ```

* It is now possible to set an image property to make recursive operations
  the default behaviour and also to specify the default concurrency for
  package operations. So if you routinely use `pkg udpate -r -C 0` then you
  can now:

    ```
	# pkg set-property default-recurse True
	# pkg set-property recursion-concurrency 0
    ```

  The new `-R` option allows temporary override for recursion, refer to the
  `pkg.1` man page for more details.

* The `pkg set-publisher -O` option is now documented and has been extended
  to support bare and relative path-names. This is now the recommended way
  to switch releases - see [upgrade notes](https://omniosce.org/upgrade)

* A number of core packages can now be removed if not required. In particular
  removing packages which require a reboot on upgrade will mean that the
  reboot is avoided if that package is updated upstream. The list can be
  viewed with `pkg contents -m entire | grep optional`. This in addition
  to the _runtime/java_ _java/jdk_ and _service/resource-pools/poold_
  packages which became optional in the last release.

* `pkgsign` has gained `--dkey` and `--dcert` options to enable use of an
  SSL client certificate when signing packages in a remote HTTPS repository.

* `pkg install` now permits package downgrades.

* `pkg history -o time,command -n 5` now works as expected.

### LX zones

* The IP address information for an interface in an LX zone can now be
  set directly via the `allowed-address` and `defrouter` properties instead
  of by using attributes. In addition to setting the address within the
  zone, this also enables L3 protection on the interface so that it can
  no longer be changed from inside the zone. The old method of setting
  attributes is still supported but does not afford this protection.
    ```
	GZ# zonecfg -z lx info net
	net:
		address not specified
		allowed-address: 172.30.1.129/26
		defrouter: 172.30.1.254
		physical: deb0

	GZ# dladm show-linkprop deb0
	LINK         PROPERTY        PERM VALUE          DEFAULT        POSSIBLE
	deb0         protection      rw   ip-nospoof     --             
	deb0         allowed-ips     rw   172.30.1.129/32 --            --
    ```

* Any secondary file-systems mounted within /usr, /lib or /sbin are no longer
  accessible from within an LX zone through /native/.

* Report that `/proc/sys` is writable to keep _systemd_ happy.

* More complete emulation of `/proc/mounts`.

* Emulate a userspace clock of 100Hz to accommodate some broken applications.

* Support for joining multicast group.

* Many other fixes and compatibility updates from Joyent.

### Hardware Support

* Better support for AMD Ryzen processors.

* Support for Sound Blaster Audigy RX.

### Commands and Command Options

* ZFS now supports the removal of a top-level vdev from a pool via
  `zfs remove`, reducing the total amount of storage in the pool without
  requiring a pool rebuild. More information ca be found in
  [illumos Issue 7614](https://www.illumos.org/issues/7614).

* `/bin/uname -o` and `/usr/gnu/bin/uname -o` report `illumos` as the
  operating system name.

* `grep` now supports context options (-A, -B, -C)

* `date -r` to display the date associated with an epoch value, or the
  timestamp of a file.

* The `reboot now` command, as sometimes mistyped due to its prevelance on
  other system types, no longer breaks booting due to trying to load a
  kernel called `now`; the system now always falls back to `unix` for the
  default kernel.

### Developer Features

* GCC version 7 is now available - `pkg install developer/gcc7` - and can be
  found in `/opt/gcc-7`.
  Details of the changes in GCC 7 can be found on
  [the gcc web site](https://gcc.gnu.org/gcc-7/changes.html).

* Perl has been upgraded to 5.26.X. The version of perl shipped with OmniOS
  is for internal system use and should not be relied on for anything else.

* MDB smart-write feature via `/z` - see
  [illumos issue 9091](https://www.illumos.org/issues/9091)

### Deprecated features

* Several legacy SunSSH compatibility options for OpenSSH are deprecated
  with this release and should be removed from SSH daemon configuration
  files. A future release of OmniOS will remove support for these options
  completely. Refer to
  [https://omniosce.org/info/sunssh](https://omniosce.org/info/sunssh)
  for more details.

* The python `m2crypto`, `typing`, `lxml` and `pyrex` modules
  have been removed as they are no longer required by core OmniOS packages.

### Package changes ([+] Added, [-] Removed, [\*] Changed)

XXX

