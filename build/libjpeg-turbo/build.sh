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

PROG=libjpeg-turbo
VER=2.0.4
PKG=ooce/library/libjpeg-turbo
SUMMARY="libjpeg-turbo"
DESC="SIMD-accelerated libjpeg-compatible JPEG codec library"

BUILD_DEPENDS_IPS="
    ooce/developer/cmake
    developer/nasm
"

OPREFIX=$PREFIX
PREFIX+="/$PROG"

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
"

CONFIGURE_OPTS="
    -DCMAKE_BUILD_TYPE=Release
    -DENABLE_STATIC=0
    -DCMAKE_INSTALL_PREFIX=$PREFIX
    -DCMAKE_INSTALL_INCLUDEDIR=$OPREFIX/include
"
CONFIGURE_OPTS_32="
    -DCMAKE_INSTALL_LIBDIR=$OPREFIX/lib
"
CONFIGURE_OPTS_64="
    -DCMAKE_INSTALL_LIBDIR=$OPREFIX/lib/amd64
"

init
download_source $PROG $PROG $VER
prep_build cmake
patch_source
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
