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

PROG=lz4
PKG=ooce/compress/lz4
VER=1.9.2
VERHUMAN=$VER
SUMMARY="LZ4"
DESC="Extremely fast compression"

OPREFIX=$PREFIX
PREFIX+=/$PROG

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
    -DVERSION=$VER
"

# we build/ship 32 and 64bit libraries but only 64bit binaries
configure32() {
    MAKE_ARGS_WS="
        CFLAGS=\"$CFLAGS $CFLAGS32\"
        LDFLAGS=\"$LDFLAGS $LDFLAGS32\"
    "
}
configure64() {
    MAKE_ARGS_WS="
        CFLAGS=\"$CFLAGS $CFLAGS64\"
        LDFLAGS=\"$LDFLAGS $LDFLAGS64\"
    "
}

MAKE_INSTALL_ARGS="
    INSTALL=install
    PREFIX=$PREFIX
    INCLUDEDIR=$OPREFIX/include
"
MAKE_INSTALL_ARGS_32="LIBDIR=$OPREFIX/lib"
MAKE_INSTALL_ARGS_64="LIBDIR=$OPREFIX/lib/$ISAPART64"

init
download_source $PROG "v$VER"
patch_source
prep_build
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
