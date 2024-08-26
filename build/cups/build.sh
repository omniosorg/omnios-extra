#!/usr/bin/bash
#
# {{{ CDDL HEADER
#
# This file and its contents are supplied under the terms of the
# Common Development and Distribution License ("CDDL"), version 1.0.
# You may only use this file in accordance with the terms of version
# 1.0 of the CDDL.
#
# A full copy of the text of the CDDL should have accompanied this
# source. A copy of the CDDL is also available via the Internet at
# http://www.illumos.org/license/CDDL.
# }}}

# Copyright 2024 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=cups
VER=2.4.10
PKG=ooce/print/cups
SUMMARY="Common UNIX Printing System"
DESC="Standards-based, open source printing system for UNIX operating systems"

set_clangver

# getpwuid_r
set_standard XPG6

OPREFIX=$PREFIX
PREFIX+="/$PROG"
VARDIR="/var$PREFIX"

forgo_isaexec

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
    -DPKGROOT=$PROG
"

CONFIGURE_OPTS="
    --sysconfdir=/etc$OPREFIX
    --includedir=$OPREFIX/include
    --localstatedir=$VARDIR
    --with-logdir=/var/log$PREFIX
    --with-domainsocket=$VARDIR/run/cups
    --with-smfmanifestdir=/lib/svc/manifest/application
    --with-cups-user=lp
    --with-cups-group=lp
    --enable-debug
    --disable-static
    --without-bundledir
    --without-icondir
    --without-menudir
    --without-rcdir
    --without-dnssd
    --without-systemd
    --without-python
    --without-php
    --without-java
"

# cups uses libusb_get_device_list to enumerate devices
# this currently fails in zones as it uses libdevinfo
CONFIGURE_OPTS+=" --disable-libusb"

CPPFLAGS+=" -DOOCEVER=$RELVER"

pre_configure() {
    typeset arch=$1

    CONFIGURE_OPTS[$arch]+=" --libdir=$OPREFIX/${LIBDIRS[$arch]}"
    LDFLAGS[$arch]+=" -L${SYSROOT[$arch]}/usr/${LIBDIRS[$arch]}"
    LDFLAGS[$arch]+=" -Wl,-R$OPREFIX/${LIBDIRS[$arch]}"
    LDFLAGS[$arch]+=" -lsocket"

    export DSOFLAGS="$LDFLAGS ${LDFLAGS[$arch]}"
}

init
download_source $PROG $PROG $VER-source
patch_source
prep_build
run_autoconf -f
build
VER=${VER//op/.} make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
