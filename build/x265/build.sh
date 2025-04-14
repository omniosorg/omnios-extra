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

PROG=x265
VER=3.4
PKG=ooce/multimedia/x265
SUMMARY="H.265/MPEG-H HEVC encoder"
DESC="Free software library and application for encoding video streams "
DESC+="into the H.265/MPEG-H HEVC compression format"

set_builddir $PROG-$VER/source

CONFIGURE_OPTS[i386]=" -DLIB_INSTALL_DIR=${LIBDIRS[i386]}"
CONFIGURE_OPTS[amd64]=" -DLIB_INSTALL_DIR=${LIBDIRS[amd64]}"
CONFIGURE_OPTS[aarch64]="
    -DLIB_INSTALL_DIR=${LIBDIRS[aarch64]}
    -DCROSS_COMPILE_ARM=ON
    -DENABLE_ASSEMBLY=OFF
"

CONFIGURE_OPTS="
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_INSTALL_PREFIX=$PREFIX
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5
"

CXXFLAGS[aarch64]+=" -mno-outline-atomics"

LDFLAGS[amd64]+=" -R$PREFIX/${LIBDIRS[amd64]}"
LDFLAGS[aarch64]+=" -R$PREFIX/${LIBDIRS[aarch64]}"

fix_version() {
    pushd $TMPDIR/$BUILDDIR >/dev/null

    logcmd sed -i "/^set(X265_LATEST_TAG/c\\
set(X265_LATEST_TAG \"$VER\")
    " cmake/version.cmake || logerr "failed to set version"

    popd >/dev/null
}

post_install() {
    typeset arch=$arch

    [ -n "$INSTALL_TARG" ] || return
    typeset src=$DESTDIR/$PREFIX/lib/$arch/libx265.a
    [ -f "$src" ] || src=$DESTDIR/$PREFIX/lib/libx265.a
    $MKDIR -p $TMPDIR/_deproot/
    $CP $src $TMPDIR/_deproot/$INSTALL_TARG.a \
        || logerr "Installation of $INSTALL_TARG.a failed"
}

run_build() {
    typeset args="$@"

    # We only need to build the 10 and 12 bit variants for 64-bit, so
    # temporarily switch to 64-bit only.
    save_variable BUILDARCH
    set_arch 64 default

    save_buildenv
    save_builddir __x265_save__

    note -n "-- Building $PROG 10bit"
    append_builddir "10bit"
    CONFIGURE_OPTS[$BUILDARCH]+="
        -DHIGH_BIT_DEPTH=ON
        -DEXPORT_C_API=OFF
        -DENABLE_SHARED=OFF
        -DENABLE_CLI=OFF
    "
    INSTALL_TARG=libx265_main10 build $args

    note -n "-- Building $PROG 12bit"
    restore_builddir __x265_save__
    append_builddir "12bit"
    CONFIGURE_OPTS[$BUILDARCH]+=" -DMAIN12=ON"
    INSTALL_TARG=libx265_main12 build $args

    restore_builddir __x265_save__
    restore_buildenv
    unset INSTALL_TARG

    CONFIGURE_OPTS[$BUILDARCH]+="
        -DEXTRA_LIB=x265_main10.a;x265_main12.a
        -DEXTRA_LINK_FLAGS=-L$TMPDIR/_deproot
        -DLINKED_10BIT=ON -DLINKED_12BIT=ON
    "

    restore_variable BUILDARCH

    note -n "-- Building $PROG 8bit"
    build $args

    # Check that we have been built with the 10- and 12-bit support that we
    # need.
    if ! is_cross; then
        set_arch 64
        LD_LIBRARY_PATH=$DESTDIR/$PREFIX/${LIBDIRS[$BUILDARCH]} \
            $DESTDIR/$PREFIX/bin/$PROG --version 2>&1 \
            | $FGREP -s '8bit+10bit+12bit' \
            || logerr 'Final library depth support is lacking'
    fi
}

init
download_source $PROG $VER
patch_source
fix_version
prep_build cmake+ninja
run_build -noctf    # C++
strip_install
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
