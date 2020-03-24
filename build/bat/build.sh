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

# Copyright 2020 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/functions.sh

PROG=bat
VER=0.13.0
PKG=ooce/util/bat
SUMMARY="cat alternative"
DESC="A cat(1) clone with wings"

# clang is a build-time requirement for 0.12.x
CLANGVER=9.0

if [ $RELVER -lt 151028 ]; then
    logmsg "--- $PKG is not built for r$RELVER"
    exit 0
fi

BUILD_DEPENDS_IPS="ooce/developer/rust ooce/developer/clang-${CLANGVER//./}"

set_arch 64

export LIBCLANG_PATH="$PREFIX/clang-$CLANGVER/lib"

build() {
    logmsg "Building 64-bit"
    pushd $TMPDIR/$BUILDDIR >/dev/null
    logcmd cargo update -p libc
    args="--release"
    logcmd cargo build $args || logerr "build failed"
    popd >/dev/null
}

install() {
    logmsg "Installing"
    pushd $TMPDIR/$BUILDDIR >/dev/null

    logcmd mkdir -p $DESTDIR/$PREFIX/bin
    logcmd cp target/release/bat $DESTDIR/$PREFIX/bin/bat || logerr "cp failed"

    logcmd mkdir -p $DESTDIR/$PREFIX/share/man/man1
    logcmd cp target/release/build/bat-*/out/assets/manual/bat.1 \
        $DESTDIR/$PREFIX/share/man/man1/ || logerr "cp failed"

    popd >/dev/null
}

init
download_source $PROG v$VER ""
patch_source
prep_build
build
install
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
