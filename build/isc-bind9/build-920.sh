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
# Copyright 2026 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=bind
VER=9.20.18
PKG=ooce/network/bind-920
SUMMARY="ISC BIND DNS Server & Tools"
DESC="Server & Client Utilities for DNS"

BUILD_DEPENDS_IPS="
    ooce/database/lmdb
    ooce/library/json-c
    ooce/library/liburcu
    ooce/library/libuv
"

RUN_DEPENDS_IPS="
    ooce/network/bind-common
"

set_arch 64
set_standard XPG4v2 CFLAGS

# configure complains about make not being GNU make
export MAKE

MAJVER=${VER%.*}            # M.m
sMAJVER=${MAJVER//./}       # Mm
set_patchdir patches-$sMAJVER

OPREFIX=$PREFIX
PREFIX+=/named-$MAJVER
CONFPATH=/etc$PREFIX
VARPATH=/var$OPREFIX/named/named-$MAJVER

HARDLINK_TARGETS="
    ${PREFIX#/}/bin/named-checkzone
    ${PREFIX#/}/sbin/tsig-keygen
"

SKIP_RTIME_CHECK=1
NO_SONAME_EXPECTED=1

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
    --with-zlib=yes
    --with-libxml2=yes
    --with-json-c=yes
    --with-lmdb=$OPREFIX
"

# for lmdb
LDFLAGS[amd64]+=" -L$OPREFIX/lib/amd64 -R$OPREFIX/lib/amd64"

init
download_source $PROG $PROG $VER
patch_source
xform files/named.conf-template > $TMPDIR/named-$sMAJVER.conf
prep_build autoconf -autoreconf
build
xform files/named-template.xml > $TMPDIR/named-$sMAJVER.xml
xform files/named-template > $TMPDIR/named-$sMAJVER
install_smf -oocemethod ooce named-$sMAJVER.xml named-$sMAJVER
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
