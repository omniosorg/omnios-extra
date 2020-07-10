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

# Copyright 2020 OmniOS Community Edition.

. ../../lib/functions.sh

PROG=apr-util
VER=1.6.1
PKG=ooce/library/apr-util
SUMMARY="Utilities for the Apache Portable Runtime library"
DESC="The Apache Portable Runtime is a library \
of C data structures and routines, forming a system portability \
layer that covers as many operating systems as possible, including \
Unices, Win32, BeOS, OS/2."

BUILD_DEPENDS_IPS+="
    ooce/library/apr
"

CONFIGURE_OPTS="
    --with-openssl
    --with-crypto
    --without-pgsql
    --with-gdbm
"

CONFIGURE_OPTS_32+="
    --with-apr=$PREFIX/bin/$ISAPART/apr-1-config
    --with-berkeley-db=$PREFIX/include:$PREFIX/lib
"

CONFIGURE_OPTS_64+="
    --with-apr=$PREFIX/bin/$ISAPART64/apr-1-config
    --with-berkeley-db=$PREFIX/include:$PREFIX/lib/$ISAPART64
"

LDFLAGS32+=" -L$PREFIX/lib -R$PREFIX/lib"
LDFLAGS64+=" -L$PREFIX/lib/$ISAPART64 -R$PREFIX/lib/$ISAPART64"

init
download_source apr $PROG $VER
patch_source
prep_build
build
run_testsuite
strip_install
make_isa_stub
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
