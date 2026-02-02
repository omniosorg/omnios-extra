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

PROG=libjpeg-turbo
VER=3.1.3
PKG=ooce/library/libjpeg-turbo
SUMMARY="libjpeg-turbo"
DESC="SIMD-accelerated libjpeg-compatible JPEG codec library"

BUILD_DEPENDS_IPS="
    ooce/developer/cmake
    developer/nasm
"

set_clangver

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
"

TESTSUITE_SED='
    1,/^Test project/d
    s/  *[0-9][0-9.]*  *sec//
'

CONFIGURE_OPTS="
    -DCMAKE_BUILD_TYPE=Release
    -DENABLE_STATIC=0
    -DCMAKE_INSTALL_PREFIX=$PREFIX
"

CFLAGS[aarch64]+=" -mtls-dialect=trad"

pre_build() {
    typeset arch=$1

    CONFIGURE_OPTS[$arch]="-DCMAKE_INSTALL_LIBDIR=${LIBDIRS[$arch]}"

    ! cross_arch $arch && return

    CONFIGURE_OPTS[$arch]+="
        -DCMAKE_TOOLCHAIN_FILE=$SRCDIR/files/cmake-toolchain-$arch.txt
    "
}

init
download_source $PROG $PROG $VER
prep_build cmake+ninja
patch_source
build
run_testsuite
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
