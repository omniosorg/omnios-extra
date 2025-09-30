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

PROG=ffmpeg
VER=8.0
PKG=ooce/multimedia/ffmpeg
SUMMARY="ffmpeg"
DESC="A complete, cross-platform solution to record, "
DESC+="convert and stream audio and video."

# Previous versions that also need to be built and packaged since compiled
# software may depend on it.
PVERS="4.4.5 5.1.6 6.1.2 7.1.1"

set_clangver

# The rav1e ABI changes frequently. Lock the version
# pulled into each build of ffmpeg.
RAV1EVER=`pkg_ver rav1e`
RAV1EVER=${RAV1EVER%.*}
BUILD_DEPENDS_IPS="=ooce/multimedia/rav1e@$RAV1EVER"
RUN_DEPENDS_IPS="$BUILD_DEPENDS_IPS"

OPREFIX=$PREFIX
PREFIX+="/$PROG"

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
    -DPKGROOT=$PROG
"

# ffmpeg contains BMI instructions even when built on an older CPU
BMI_EXPECTED=1

CONFIGURE_OPTS="
    --prefix=$PREFIX
    --incdir=$OPREFIX/include
    --disable-static
    --enable-shared
    --disable-debug
    --disable-stripping
    --enable-libdav1d
    --enable-libfontconfig
    --enable-libfreetype
    --enable-libvorbis
    --enable-libwebp
    --enable-gpl
    --enable-libx264
    --enable-libx265
    --enable-gnutls
"
CONFIGURE_OPTS[i386]="
    --disable-librav1e
"
CONFIGURE_OPTS[amd64]="
    --enable-librav1e
"
CONFIGURE_OPTS[aarch64]="
    --enable-librav1e
"

pre_configure() {
    typeset arch=$1

    CONFIGURE_OPTS+="
        --cc=$CC
        --cxx=$CXX
    "

    CONFIGURE_OPTS[$arch]+="
        --libdir=$OPREFIX/${LIBDIRS[$arch]}
    "

    # to find x264.h for builtin check
    CPPFLAGS+=" -I${SYSROOT[$arch]}$OPREFIX/include"

    LDFLAGS[$arch]+=" -Wl,-R$OPREFIX/${LIBDIRS[$arch]}"

    ! cross_arch $arch && return

    CONFIGURE_OPTS[$arch]+="
        --enable-cross-compile
        --disable-asm
        --sysroot=${SYSROOT[$arch]}
        --host-cc=/opt/gcc-$DEFAULT_GCC_VER/bin/gcc
    "
}

init
prep_build autoconf-like

# Skip previous versions for cross compilation
pre_build() { ! cross_arch $1; }

# Build previous versions
for pver in $PVERS; do
    note -n "Building previous version: $pver"
    set_builddir $PROG-$pver
    save_variable CONFIGURE_OPTS
    CONFIGURE_OPTS+=" --disable-programs --disable-doc"
    download_source -dependency $PROG $PROG $pver
    patch_source patches-`echo $pver | cut -d. -f1-2`
    build
    restore_variable CONFIGURE_OPTS
done
unset -f pre_build

note -n "Building current version: $VER"

set_builddir $PROG-$VER
download_source $PROG $PROG $VER
patch_source
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
