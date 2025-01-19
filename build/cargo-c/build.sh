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

PROG=cargo-c
VER=0.10.8
PKG=ooce/developer/cargo-c
SUMMARY="build and install C-ABI compatible dynamic and static libraries"
DESC="produces and installs a correct pkg-config file, a static library and "
DESC+="a dynamic library, and a C header to be used by any C "
DESC+="(and C-compatible) software."

RUSTVER=`pkg_ver rust`
RUSTVER=${RUSTVER%.*}
BUILD_DEPENDS_IPS="
    =ooce/developer/rust@$RUSTVER
"
RUN_DEPENDS_IPS="
    ooce/developer/rust
    $BUILD_DEPENDS_IPS
"

set_arch 64

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
"

SKIP_RTIME_CHECK=1
SKIP_SSP_CHECK=1

build() {
    logmsg "Building 64-bit"

    pushd $TMPDIR/$BUILDDIR >/dev/null

    logcmd $CARGO install --locked --root=$DESTDIR$PREFIX --path=. \
        || logerr "build failed"

    popd >/dev/null
}

init
download_source $PROG v$VER
patch_source
prep_build
build
strip_install
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
