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

PROG=rav1e
VER=0.7.1
PKG=ooce/multimedia/rav1e
SUMMARY="$PROG - AV1 encoder"
DESC="AV1 video encoder"

BUILD_DEPENDS_IPS="
    ooce/developer/cargo-c
"

set_arch 64

# illumos strip removes symbol tables from archives
export STRIP=$GNUBIN/strip

post_build() {
    typeset arch=$1

    _destdir=$DESTDIR
    cross_arch $arch && _destdir+=.$arch

    pushd $TMPDIR/$BUILDDIR >/dev/null

    logcmd $CARGO cinstall --release --target=${RUSTTRIPLETS[$arch]} \
        --library-type=cdylib --destdir=$_destdir --prefix=$PREFIX \
        --libdir=$PREFIX/${LIBDIRS[$arch]} \
        || logerr "C-API build failed"

    popd >/dev/null
}

init
download_source $PROG v$VER
patch_source
prep_build
build_rust
install_rust
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
