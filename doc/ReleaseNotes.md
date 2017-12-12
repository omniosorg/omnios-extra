<a href="https://omniosce.org">
<img src="https://omniosce.org/OmniOSce_logo.svg" height="128">
</a>

# Release Notes for OmniOSce v11 r151026
![#f03c15](https://placehold.it/15/f03c15/000000?text=+) ** These are DRAFT release notes ** ![#f03c15](https://placehold.it/15/f03c15/000000?text=+)

Stable Release, TBC of May 2018

illumos-omnios branch r151026 at XXX

`uname -a` shows `omnios-r151026-XXX`

r151026 release repository: https://pkg.omniosce.org/r151026/core

## New features since r151024

### System Features

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

* Experimental support for `sparse` zones. These are linked-ipkg zones that
  share the `/usr`, `/sbin` and `/lib` directories with the global zone.
  They are tiny (under 4MiB of installed files) and perfect for isolating
  VM instances for extra security or to apply more granular resource controls.

* A number of system components now enable Address Space Layout Randomisation
  (ASLR) by default:
    * OpenSSH daemon
    * pfexecd
    * rpcbind
    * Sendmail
    * Dragonfly Mail Agent

* `openssh` has been upgraded to 7.6p1. This version drops support for
  SSH protocol version 1, RSA keys under 1024 bits in length and a number
  of old ciphers and MACs. Refer to
  [the release notes](https://www.openssh.com/txt/release-7.6) for more
  details.

* `libdiskmgt` (and therefore `diskinfo`) now recognises nvme, sata and xen
  controllers

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

* IPv6 default address selection table updated for RFC6724

### LX zones

* Report that `/proc/sys` is writable to keep systemd happy.

* Emulate a userspace clock of 100Hz to accommodate some broken applications.

* support for joining multicast group

### Hardware Support

### Commands and Command Options

* `/usr/gnu/bin/uname -o` reports `illumos` as the operating system.

* `grep` now supports context options (-A, -B, -C)

* `pkgsign` has gained `--dkey` and `--dcert` options to enable use of an
  SSL client certificate when signing packages in a remote HTTPS repository.

* `pkg install` now permits package downgrades.

### Developer Features

* GCC version 7 is now available - `pkg install developer/gcc7` - and can be
  found in `/opt/gcc-7`.
  Details of the changes in GCC 7 can be found on
  [the gcc web site](https://gcc.gnu.org/gcc-7/changes.html).

* Perl has been upgraded to 5.26.X. The version of perl shipped with OmniOS
  is for internal system use and should not be relied on for anything else.

### Deprecated features

* The python `m2crypto`, `typing`, `lxml` and `pyrex` modules
  have been removed as they are no longer required by core OmniOS packages.

### Package changes ([+] Added, [-] Removed, [\*] Changed)

XXX

