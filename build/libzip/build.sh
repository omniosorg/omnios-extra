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

# Copyright 2025 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=libzip
VER=1.11.4
PKG=ooce/library/libzip
SUMMARY="libzip"
DESC="A C library for reading, creating and modifying zip archives"

# refrain from building this package with clang as it adds
# nullability attributes to headers which cause issues when
# being used with gcc

OPREFIX=$PREFIX
PREFIX+="/$PROG"

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
    -DPKGROOT=$PROG
"

CONFIGURE_OPTS="
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_INSTALL_PREFIX=$PREFIX
    -DCMAKE_INSTALL_INCLUDEDIR=$OPREFIX/include
"

pre_configure() {
    typeset arch=$1

    CONFIGURE_OPTS[$arch]="-DCMAKE_INSTALL_LIBDIR=$OPREFIX/${LIBDIRS[$arch]}"
    LDFLAGS[$arch]+=" -R$OPREFIX/${LIBDIRS[$arch]}"

    ! cross_arch $arch && return

    export CMAKE_LIBRARY_PATH=${SYSROOT[$arch]}/usr/${LIBDIRS[$arch]}
}

init
download_source $PROG $PROG $VER
prep_build cmake+ninja
patch_source
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
