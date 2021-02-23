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

# Copyright 2021 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/functions.sh

PROG=x265
VER=3.4
PKG=ooce/multimedia/x265
SUMMARY="H.265/MPEG-H HEVC encoder"
DESC="Free software library and application for encoding video streams "
DESC+="into the H.265/MPEG-H HEVC compression format"

set_builddir $PROG-$VER/source

CMAKE+=" -G Ninja"
MAKE=$NINJA

CONFIGURE_OPTS_32="
    -DLIB_INSTALL_DIR=lib
"
CONFIGURE_OPTS_64="
    -DLIB_INSTALL_DIR=lib/$ISAPART64
"
CONFIGURE_OPTS="
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_INSTALL_PREFIX=$PREFIX
"

LDFLAGS64+=" -R$PREFIX/lib/$ISAPART64"

fix_version() {
    pushd $TMPDIR/$BUILDDIR >/dev/null

    logcmd sed -i "/^set(X265_LATEST_TAG/c\\
set(X265_LATEST_TAG \"$VER\")
    " cmake/version.cmake || logerr "failed to set version"

    popd >/dev/null
}

save_function build64 _build64
build64() {
    [ -d "$TMPDIR/_deproot" ] || mkdir -p $TMPDIR/_deproot \
        || logerr "mkdir _deproot failed"

    save_buildenv

    note -n "-- Building $PROG 10bit"
    save_variable BUILDDIR
    BUILDDIR+="/10bit"
    logcmd mkdir -p $TMPDIR/$BUILDDIR || logerr "mkdir failed"
    CONFIGURE_OPTS_64+="
        -DHIGH_BIT_DEPTH=ON
        -DEXPORT_C_API=OFF
        -DENABLE_SHARED=OFF
        -DENABLE_CLI=OFF
    "
    _build64
    logcmd cp -f $TMPDIR/$BUILDDIR/libx265.a $TMPDIR/_deproot/libx265_main10.a \
        || logerr "cp libx265.a failed"
    restore_variable BUILDDIR

    note -n "-- Building $PROG 12bit"
    save_variable BUILDDIR
    BUILDDIR+="/12bit"
    logcmd mkdir -p $TMPDIR/$BUILDDIR || logerr "mkdir failed"
    CONFIGURE_OPTS_64+="
        -DMAIN12=ON
    "
    _build64
    logcmd cp -f $TMPDIR/$BUILDDIR/libx265.a $TMPDIR/_deproot/libx265_main12.a \
        || logerr "cp libx265.a failed"
    restore_variable BUILDDIR

    restore_buildenv

    note -n "-- Building $PROG 8bit"
    CONFIGURE_OPTS_64+="
        -DEXTRA_LIB=x265_main10.a;x265_main12.a
        -DEXTRA_LINK_FLAGS=-L$TMPDIR/_deproot
        -DLINKED_10BIT=ON -DLINKED_12BIT=ON
    "
    _build64
}

init
download_source $PROG $VER
patch_source
fix_version
prep_build cmake
build -noctf    # C++
strip_install
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
