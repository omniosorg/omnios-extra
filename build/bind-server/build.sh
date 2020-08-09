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
# Copyright 2020 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/functions.sh

PROG=bind
VER=9.11.21
PKG=network/bind-server
SUMMARY="BIND DNS Server & Tools"
DESC="Server & Client Utilities for DNS"

set_arch 64

SKIP_LICENCES="*"

OPREFIX=$PREFIX
PREFIX+=/$PROG

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
"

CONFIGURE_OPTS="
    --sysconfdir=/etc/$PREFIX
    --localstatedir=/var/$PREFIX
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
prep_build
run_autoreconf -fi
build
strip_install
install_smf network/dns named.xml
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
