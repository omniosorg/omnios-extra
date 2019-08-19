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

# Copyright 2019 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/functions.sh

PROG=cups
VER=2.2.12
PKG=ooce/print/cups
SUMMARY="Common UNIX Printing System"
DESC="Standards-based, open source printing system for UNIX operating systems"

OPREFIX=$PREFIX
PREFIX+="/$PROG"
VARDIR="/var$PREFIX"

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
"

CONFIGURE_OPTS="
    --prefix=$PREFIX
    --sysconfdir=/etc$OPREFIX
    --includedir=$OPREFIX/include
    --localstatedir=$VARDIR
    --with-logdir=/var/log$PREFIX
    --with-domainsocket=$VARDIR/run/cups
    --with-smfmanifestdir=/lib/svc/manifest/application
    --with-cups-user=lp
    --with-cups-group=lp
    --disable-static
    --disable-gnutls
    --without-bundledir
    --without-icondir
    --without-menudir
    --without-python
    --without-php
    --without-java
"

CONFIGURE_OPTS_32="
    --libdir=$OPREFIX/lib
"
CONFIGURE_OPTS_64="
    --libdir=$OPREFIX/lib/$ISAPART64
"

CFLAGS+=" -I$OPREFIX/include"
LDFLAGS32+=" -L$OPREFIX/lib -R$OPREFIX/lib"
LDFLAGS64+=" -L$OPREFIX/lib/$ISAPART64 -R$OPREFIX/lib/$ISAPART64"

init
download_source $PROG $PROG $VER-source
patch_source
prep_build
run_autoconf -f
# cups does not use DESTDIR but DSTROOT
DSTROOT=$DESTDIR build
strip_install
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
