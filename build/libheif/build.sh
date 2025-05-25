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

PROG=libheif
VER=1.19.8
PKG=ooce/library/libheif
SUMMARY="HEIF and AVIF encoder"
DESC="ISO/IEC 23008-12:2017 HEIF and AVIF (AV1 Image File Format) "
DESC+="file format decoder and encoder"

test_relver '>=' 151047 && set_clangver

# The rav1e ABI changes frequently. Lock the version
# pulled into each build of libheif.
RAV1EVER=`pkg_ver rav1e`
RAV1EVER=${RAV1EVER%.*}

# TODO: we don't cross build rust software, yet. but the rav1e build-time
# dependency is met on the build host
BUILD_DEPENDS_IPS="
    ooce/library/libde265
    ooce/multimedia/dav1d
    =ooce/multimedia/rav1e@$RAV1EVER
    ooce/multimedia/x265
"

XFORM_ARGS="-DPREFIX=${PREFIX#/}"

CONFIGURE_OPTS="
    --preset=release
    -DCMAKE_INSTALL_PREFIX=$PREFIX
    -DWITH_EXAMPLES=OFF
"

pre_configure() {
    typeset arch=$1

    ! cross_arch $arch && RUN_DEPENDS_IPS="=ooce/multimedia/rav1e@$RAV1EVER"

    export CMAKE_LIBRARY_PATH=${SYSROOT[$arch]}$PREFIX/${LIBDIRS[$arch]}

    CONFIGURE_OPTS[$arch]="
        -DCMAKE_INSTALL_LIBDIR=$PREFIX/${LIBDIRS[$arch]}
        -DZLIB_INCLUDE_DIR=${SYSROOT[$arch]}/usr/include
        -DZLIB_LIBRARY_RELEASE=${SYSROOT[$arch]}/usr/${LIBDIRS[$arch]}/libz.so
        -DBROTLI_DEC_INCLUDE_DIR=${SYSROOT[$arch]}/usr/include
        -DBROTLI_DEC_LIB=${SYSROOT[$arch]}/usr/${LIBDIRS[$arch]}/libbrotlidec.so
        -DBROTLI_ENC_INCLUDE_DIR=${SYSROOT[$arch]}/usr/include
        -DBROTLI_ENC_LIB=${SYSROOT[$arch]}/usr/${LIBDIRS[$arch]}/libbrotlienc.so
    "

    cross_arch $arch && CONFIGURE_OPTS[$arch]+=" -DWITH_RAV1E=OFF"

    LDFLAGS[$arch]+=" -Wl,-R$PREFIX/${LIBDIRS[$arch]}"
}

CXXFLAGS[aarch64]+=" -mtls-dialect=trad"

init
download_source $PROG $PROG $VER
patch_source
prep_build cmake+ninja
build -noctf    # C++
strip_install
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
