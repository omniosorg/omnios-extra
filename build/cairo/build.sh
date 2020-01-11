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

PROG=cairo
VER=1.16.0
PKG=ooce/library/cairo
SUMMARY="cairo"
DESC="Cairo is a 2D graphics library with support for multiple output devices"

# Cairo depends on pixman
PIXMANVER=0.38.4

BUILD_DEPENDS_IPS="
    ooce/library/fontconfig
    ooce/library/freetype2
    ooce/library/libpng
"

OPREFIX=$PREFIX
PREFIX+="/$PROG"

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
    -DPIXMAN=$PIXMANVER
"

init
prep_build

######################################################################

CONFIGURE_OPTS="
    --disable-static
"
build_dependency -merge pixman pixman-$PIXMANVER pixman pixman $PIXMANVER
export pixman_CFLAGS="-I$DEPROOT/$OPREFIX/include/pixman-1"
export pixman_LIBS="-lpixman-1"
LDFLAGS32+=" -L$DEPROOT/$OPREFIX/lib"
LDFLAGS64+=" -L$DEPROOT/$OPREFIX/lib/amd64"
logcmd find $DEPROOT -name \*.la -exec rm {} +

######################################################################

CONFIGURE_OPTS="
    --prefix=$PREFIX
    --disable-static
    --includedir=$OPREFIX/include
"
CONFIGURE_OPTS_32="
    --bindir=$PREFIX/bin/$ISAPART
    --libdir=$OPREFIX/lib
"
CONFIGURE_OPTS_64="
    --bindir=$PREFIX/bin
    --libdir=$OPREFIX/lib/$ISAPART64
"

LDFLAGS32+=" -R$OPREFIX/lib"
LDFLAGS64+=" -R$OPREFIX/lib/$ISAPART64"
addpath PKG_CONFIG_PATH32 $OPREFIX/lib/pkgconfig
addpath PKG_CONFIG_PATH64 $OPREFIX/lib/$ISAPART64/pkgconfig

note -n "-- Building $PROG"

download_source $PROG $PROG $VER
patch_source
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
