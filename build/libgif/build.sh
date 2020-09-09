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

# Copyright 2020 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/functions.sh

PROG=libgif
VER=5.2.1
PKG=ooce/library/libgif
SUMMARY="libgif"
DESC="GIFLIB is a package of portable tools and library routines for "
DESC+="working with GIF images."

set_builddir giflib-$VER

OPREFIX=$PREFIX
PREFIX+="/$PROG"

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
"

configure32() {
    MAKE_ARGS_WS="
        OFLAGS=\"$CFLAGS $CFLAGS32\"
    "
    MAKE_INSTALL_ARGS="
        PREFIX=$PREFIX
        INCDIR=$OPREFIX/include
        LIBDIR=$OPREFIX/lib
        BINDIR=$PREFIX/bin/i386
    "
}

configure64() {
    MAKE_ARGS_WS="
        OFLAGS=\"$CFLAGS $CFLAGS64\"
    "
    MAKE_INSTALL_ARGS="
        PREFIX=$PREFIX
        INCDIR=$OPREFIX/include
        LIBDIR=$OPREFIX/lib/$ISAPART64
    "
}

init
download_source $PROG giflib $VER
prep_build
patch_source
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
