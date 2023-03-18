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

. ../../lib/build.sh

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

pre_configure() {
    typeset arch=$1

    typeset bindir=bin
    [ $arch = i386 ] && bindir+=/i386

    MAKE_ARGS_WS="
        OFLAGS=\"$CFLAGS ${CFLAGS[$arch]}\"
    "
    MAKE_INSTALL_ARGS="
        PREFIX=$PREFIX
        INCDIR=$OPREFIX/include
        LIBDIR=$OPREFIX/${LIBDIRS[$arch]}
        BINDIR=$PREFIX/$bindir
    "

    # no configure
    false
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
