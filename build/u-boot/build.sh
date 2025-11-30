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

PROG=u-boot
PKG=ooce/util/u-boot
VER=2025.10
SUMMARY="Das U-Boot"
DESC="$SUMMARY: Universal Bootloader"

set_arch 64

MAKE_TARGET="sandbox_defconfig tools"
NATIVE_CC=$CC

set_args() {
    typeset arch=$1
    typeset CC=$2

    MAKE_ARGS_WS="
        V=1
        NO_PYTHON=1
        HOSTCC=\"$CC\"
        HOSTCFLAGS=\"$CFLAGS ${CFLAGS[$arch]} -I$PREFIX/include\"
        HOSTLDLIBS=\"
            $LDFLAGS ${LDFLAGS[$arch]}
            -L$PREFIX/${LIBDIRS[$arch]} -lnsl -lsocket
        \"
    "
    if cross_arch $arch; then
        MAKE_ARGS_WS+="
            HOSTLDFLAGS=\"--sysroot=${SYSROOT[$arch]}\"
        "
    fi
}

pre_configure() {
    # no configure
    false
}

make_arch() {
    typeset arch=$1

    set_args $BUILD_ARCH $NATIVE_CC
    eval set -- $MAKE_ARGS_WS
    logcmd $MAKE $MAKE_JOBS $MAKE_ARGS "$@" $MAKE_TARGET \
        || logerr "--- Make failed"

    cross_arch $arch || return

    # This is pretty horrible. U-Boot supports cross compilation for the
    # images, but not for the tools. To cross-build the tools, we need to
    # perform the full native build (as we've just done) which provides the
    # native tools that are needed for the build, and then rebuild
    # the tools. KBUILD_NOCMDDEP overrides the make system's desire to rebuild
    # everything because the build flags have changed which would result in
    # the tools required for parts of the build being built for the target
    # system and no longer runnable.
    note -n Building cross tools

    logcmd $FD -t f -e o . tools -X rm \
        || logerr "Failed to remove native objects"
    logcmd $RM -f tools/mkimage || logerr "rm tools/mkimage failed"
    set_args $arch $CC
    eval set -- $MAKE_ARGS_WS KBUILD_NOCMDDEP=1
    logcmd $MAKE $MAKE_JOBS $MAKE_ARGS "$@" tools/ \
        || logerr "--- Make cross tools failed"
}

make_install() {
    typeset dst=$DESTDIR$PREFIX/$PROG

    set -eE; trap 'logerr Installation failed at $BASH_LINENO' ERR

    # For now, this is all that's shipped in this package, which is the single
    # tool needed to build the arm64-gate. It will be extended as required.
    logcmd $MKDIR -p $dst/tools
    logcmd $CP tools/mkimage $dst/tools/

    set +eE; trap - ERR
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
