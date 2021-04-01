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

# Copyright 2021 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/functions.sh

PROG=nettle
VER=3.7.2
PKG=ooce/security/nettle
SUMMARY="nettle"
DESC="Cryptographic library"

OPREFIX=$PREFIX
PREFIX+="/$PROG"
CFLAGS+=" -I/usr/include/gmp"

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
    -DPKGROOT=$PROG
"

CONFIGURE_OPTS="
	--disable-openssl
	--disable-shared
"

init
set_mirror "http://ftp.gnu.org/gnu"
set_checksum sha256 "8d2a604ef1cde4cd5fb77e422531ea25ad064679ff0adf956e78b3352e0ef162"
download_source $PROG $PROG $VER
prep_build
build
strip_install
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
