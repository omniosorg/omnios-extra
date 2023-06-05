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

# Copyright 2023 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=rav1e
VER=0.6.6
PKG=ooce/multimedia/rav1e
SUMMARY="$PROG - AV1 encoder"
DESC="AV1 video encoder"

BUILD_DEPENDS_IPS="
    ooce/developer/cargo-c
"

set_arch 64

# illumos strip removes symbol tables from archives
export STRIP=$GNUBIN/strip

build() {
    note -n "Building $PROG"
    build_rust

    note -n "Building $PROG C-API"

    pushd $TMPDIR/$BUILDDIR >/dev/null

    logcmd $CARGO cinstall --release --library-type=cdylib \
        --destdir=$DESTDIR --prefix=$PREFIX --libdir=$PREFIX/lib/amd64 \
        || logerr "C-API build failed"

    popd >/dev/null
}

init
download_source $PROG v$VER
patch_source
prep_build
build
install_rust
strip_install
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
