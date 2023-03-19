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

# Copyright 2022 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=cairo
VER=1.16.0
PKG=ooce/library/cairo
SUMMARY="cairo"
DESC="Cairo is a 2D graphics library with support for multiple output devices"

BUILD_DEPENDS_IPS="
    ooce/library/fontconfig
    ooce/library/freetype2
    ooce/library/libpng
    ooce/library/pixman
"

OPREFIX=$PREFIX
PREFIX+="/$PROG"

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
    -DPIXMAN=$PIXMANVER
"

CONFIGURE_OPTS="
    --prefix=$PREFIX
    --disable-static
    --includedir=$OPREFIX/include
"
CONFIGURE_OPTS[i386]="
    --bindir=$PREFIX/bin/i386
    --libdir=$OPREFIX/lib
"
CONFIGURE_OPTS[amd64]="
    --bindir=$PREFIX/bin
    --libdir=$OPREFIX/lib/amd64
"

LDFLAGS[i386]+=" -R$OPREFIX/lib"
LDFLAGS[amd64]+=" -R$OPREFIX/lib/amd64"

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
