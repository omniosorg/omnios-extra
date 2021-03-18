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
#
# Copyright 2017 OmniTI Computer Consulting, Inc.  All rights reserved.
# Copyright 2021 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/functions.sh

PROG=bind
VER=9.11.29
PKG=ooce/network/bind-911
SUMMARY="ISC BIND DNS Server & Tools"
DESC="Server & Client Utilities for DNS"

RUN_DEPENDS_IPS="
    ooce/network/bind-common
"

set_arch 64

MAJVER=${VER%.*}            # M.m
sMAJVER=${MAJVER//./}       # Mm
PATCHDIR=patches-$sMAJVER

OPREFIX=$PREFIX
PREFIX+=/named-$MAJVER
CONFPATH=/etc$PREFIX
VARPATH=/var$OPREFIX/named/named-$MAJVER

HARDLINK_TARGETS="
    ${PREFIX#/}/bin/isc-config.sh
    ${PREFIX#/}/sbin/named
    ${PREFIX#/}/share/man/man1/isc-config.sh.1
    ${PREFIX#/}/share/man/man3/lwres_resutil.3
    ${PREFIX#/}/share/man/man3/lwres_buffer.3
    ${PREFIX#/}/share/man/man3/lwres_config.3
    ${PREFIX#/}/share/man/man3/lwres_context.3
    ${PREFIX#/}/share/man/man3/lwres_gethostent.3
    ${PREFIX#/}/share/man/man3/lwres_getaddrinfo.3
    ${PREFIX#/}/share/man/man3/lwres_getipnode.3
    ${PREFIX#/}/share/man/man3/lwres_gabn.3
    ${PREFIX#/}/share/man/man3/lwres_gnba.3
    ${PREFIX#/}/share/man/man3/lwres_hstrerror.3
    ${PREFIX#/}/share/man/man3/lwres_packet.3
    ${PREFIX#/}/share/man/man3/lwres_inetntop.3
    ${PREFIX#/}/share/man/man3/lwres_noop.3
"

XFORM_ARGS="
    -DOPREFIX=${OPREFIX#/}
    -DPREFIX=${PREFIX#/}
    -DCONFPATH=${CONFPATH#/}
    -DVARPATH=${VARPATH#/}
    -DPROG=$PROG
    -DPKGROOT=named-$MAJVER
    -DMEDIATOR=$PROG -DMEDIATOR_VERSION=$MAJVER
    -DVERSION=$MAJVER
    -DsVERSION=$sMAJVER
    -DUSER=named
    -DGROUP=named
"

CONFIGURE_OPTS="
    --prefix=$PREFIX
    --bindir=$PREFIX/bin
    --sbindir=$PREFIX/sbin
    --libdir=$PREFIX/lib
    --includedir=$PREFIX/include
    --sysconfdir=$CONFPATH
    --localstatedir=$VARPATH
    --with-libtool
    --with-openssl
    --enable-threads=yes
    --enable-devpoll=yes
    --enable-fixed-rrset
    --disable-getifaddrs
    --enable-shared
    --disable-static
    --without-python
    --with-zlib=/usr
"

init
download_source $PROG $PROG $VER
patch_source
xform files/named.conf-template > $TMPDIR/named-$sMAJVER.conf
prep_build
run_autoreconf -fi
build
strip_install
xform files/named-template.xml > $TMPDIR/named-$sMAJVER.xml
xform files/named-template > $TMPDIR/named-$sMAJVER
install_smf -oocemethod ooce named-$sMAJVER.xml named-$sMAJVER
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
