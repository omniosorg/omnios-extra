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

# Copyright 2018 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/functions.sh

PROG=flac
VER=1.3.2
PKG=ooce/audio/flac
SUMMARY="flac"
DESC="Free Lossless Audio Codec"

OPREFIX=$PREFIX
PREFIX+="/$PROG"

BUILD_DEPENDS_IPS="
    developer/nasm
    ooce/library/libogg
"

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
"

CONFIGURE_OPTS="
    --prefix=$PREFIX
    --includedir=$OPREFIX/include
"
CONFIGURE_OPTS_32="
    --bindir=$PREFIX/bin/$ISAPART
    --sbindir=$PREFIX/sbin/$ISAPART
    --libdir=$OPREFIX/lib
"
CONFIGURE_OPTS_64="
    --bindir=$PREFIX/bin
    --sbindir=$PREFIX/sbin
    --libdir=$OPREFIX/lib/$ISAPART64
    --build=amd64-pc-solaris2.11
"

CFLAGS+=" -I$OPREFIX/include"
LDFLAGS32+=" -L$OPREFIX/lib -R$OPREFIX/lib"
LDFLAGS64+=" -L$OPREFIX/lib/$ISAPART64 -R$OPREFIX/lib/$ISAPART64"

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
