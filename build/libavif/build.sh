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

PROG=libavif
VER=1.3.0
PKG=ooce/library/libavif
SUMMARY="$PROG"
DESC="$PROG - portable C implementation of the AV1 Image File Format"

set_clangver

TESTSUITE_SED='
    1,/^Test project/d
    s/  *[0-9][0-9.]*  *sec//
'

CONFIGURE_OPTS="
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_INSTALL_PREFIX=$PREFIX
    -DBUILD_SHARED_LIBS=ON
    -DAVIF_CODEC_DAV1D=SYSTEM
    -DAVIF_LIBYUV=LOCAL
"
CONFIGURE_OPTS[i386]="
    -DAVIF_CODEC_AOM=LOCAL
"
CONFIGURE_OPTS[amd64]="
    -DAVIF_CODEC_RAV1E=SYSTEM
    -DAVIF_BUILD_TESTS=ON
    -DAVIF_GTEST=LOCAL
"
CONFIGURE_OPTS[aarch64]="
    -DAVIF_CODEC_AOM=LOCAL
    -DAVIF_CODEC_RAV1E=SYSTEM
    -DCONFIG_RUNTIME_CPU_DETECT=0
"

pre_build() {
    typeset arch=$1

    CONFIGURE_OPTS[$arch]+=" -DCMAKE_INSTALL_LIBDIR=${LIBDIRS[$arch]}"
    LDFLAGS[$arch]+=" -Wl,-R$PREFIX/${LIBDIRS[$arch]}"

    ! cross_arch $arch && return

    CONFIGURE_OPTS[$arch]+="
        -DCMAKE_TOOLCHAIN_FILE=$SRCDIR/files/cmake-toolchain-$arch.txt
    "
}

init
download_source $PROG v$VER
patch_source
prep_build cmake+ninja
build
run_testsuite
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
