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
#
# Copyright 2025 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=micro
PROGNAME=micro
# The latest release is broken on Illumos, but the git master compiles
# at least right now. Maybe this invocation is not correct.
VER=master
PKG=ooce/editor/micro
SUMMARY="$PROG - modern and intuitive terminal-based text editor"
DESC="Micro is a terminal-based text editor that aims to be easy to use and "
DESC+="intuitive, while also taking advantage of the full capabilities of modern "
DESC+="terminals."

DESC+="As the name indicates, micro aims to be somewhat of a successor to the nano "
DESC+="editor by being easy to install and use in a pinch, but micro also aims to be "
DESC+="enjoyable to use full time, whether you work in the terminal because you "
DESC+="prefer it, or because you need to."

OPREFIX=$PREFIX
PREFIX+="/$PROG"

export BUILD_NUMBER=$VER
export PATH="$GNUBIN:$PATH"
subsume_arch $BUILDARCH PKG_CONFIG_PATH

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
"

set_arch 64
set_gover

build() {
    pushd $TMPDIR/$BUILDDIR/$PROGNAME > /dev/null
    export CGO_ENABLED=0
    export GOOS=illumos
    logcmd gmake || logerr "failed to compile micro"
    popd >/dev/null
}

install() {
    logmsg "-- installing the executable"
    pushd $TMPDIR/$BUILDDIR/$PROGNAME > /dev/null
    logcmd mkdir -p $DESTDIR/$PREFIX/bin  || logerr "can't create the prefix"
    logcmd cp $PROGNAME $DESTDIR/$PREFIX/bin/ || logerr "can't copy the $PROGNAME binary"
    popd >/dev/null
}

extract_licence() {
    logmsg "-- extracting licence"
    pushd $TMPDIR/$BUILDDIR/$PROGNAME > /dev/null
	cp LICENSE $TMPDIR/$BUILDDIR/LICENCE
	cp LICENSE-THIRD-PARTY $TMPDIR/$BUILDDIR/LICENSE-THIRD-PARTY
    popd > /dev/null
}

init
clone_github_source $PROG "$GITHUB/zyedidia/$PROG" $VER
build
install
extract_licence
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
