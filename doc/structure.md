# About Packages on OmniOSce Extra

The extra repository contains prime quality packages to enhance your omnios
system. The packages make full use of SMF and adher to the /opt package
structure. There is a separate extra repostory for each release of omnios.

## Directory Structure

immutable package files

    /opt/ooce/package-x.y

configuraton files

    /etc/opt/ooce/package-x.y

log files

    /var/log/ooce/package-x.y

other var files

    /var/opt/ooce/package-x.y

mediated symlinks provide access to binaries

    /opt/ooce/bin

mediated symlinks provide access to manual pages

    /opt/ooce/share/man*

## Multiple Versions

The nameing scheme with `application-x.y` symbolizes that the application
install directories contain a major version number. Meaning bugfix only
releases would replace a previous version, but a new major version would NOT
necessarily replace an existing one. Meaning you could install multiple
versions of perl of python or even some obscure tool in parallel. The
mediated symlinks allow you to coose the default version, but the other
versions would still be accessible by using a direct path.

## Automated Build

The build system for omnios-extra is similar to the omnios-build system,
such that all packages can be rebuild automatically.

