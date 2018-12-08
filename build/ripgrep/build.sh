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

# Copyright 2018 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/functions.sh

PROG=ripgrep
VER=0.10.0
PKG=ooce/text/ripgrep
SUMMARY="Fast line-oriented search tool"
DESC="A fast line-oriented search tool that recursively searches your current "
DESC+="directory for a regex pattern while respecting your gitignore rules"

PATH+=":$PREFIX/bin"

BUILD_DEPENDS_IPS=ooce/developer/rust
# libpcre2 is included with OmniOS as of r151029 and ripgrep can use it
[ $RELVER -ge 151029 ] && BUILD_DEPENDS_IPS+=" library/pcre2"

set_arch 64

build() {
    logmsg "Building 64-bit"
    pushd $TMPDIR/$BUILDDIR >/dev/null
    args="--release"
    [ $RELVER -ge 151029 ] && args+=" --features pcre2"
    logcmd cargo build $args || logerr "build failed"
    popd >/dev/null
}

install() {
    logmsg "Installing"
    pushd $TMPDIR/$BUILDDIR >/dev/null

    logcmd mkdir -p $DESTDIR/$PREFIX/bin
    logcmd cp target/release/rg $DESTDIR/$PREFIX/bin/rg || logerr "cp failed"
    logcmd strip -x $DESTDIR/$PREFIX/bin/rg

    logcmd mkdir -p $DESTDIR/$PREFIX/share/man/man1
    logcmd cp target/release/build/ripgrep-*/out/rg.1 \
        $DESTDIR/$PREFIX/share/man/man1/ || logerr "cp failed"

    popd >/dev/null
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
install
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
