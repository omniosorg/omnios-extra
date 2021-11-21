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

. ../../lib/build.sh

PROG=listmonk
PKG=ooce/application/listmonk
VER=2.0.0
SUMMARY="$PROG"
DESC="Self-hosted newsletter & mailing list manager"

OPREFIX=$PREFIX
PREFIX+=/$PROG

set_arch 64
set_gover 1.17
set_nodever 14

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
    -DPKGROOT=$PROG
"

GOOS=illumos
GOARCH=amd64
export GOOS GOARCH

# build expects GNU touch
export PATH=$GNUBIN:$PATH

# parallel make is currently broken
NO_PARALLEL_MAKE=1

configure64() {
    note -n "-- installing yarn"

    mkdir -p "$TMPDIR/$BUILDDIR/_deps"
    logcmd npm install --prefix $TMPDIR/$BUILDDIR/_deps yarn \
        || logerr "installing yarn failed"

    export YARN=$TMPDIR/$BUILDDIR/_deps/node_modules/yarn/bin/yarn
}

make_install64() {
    logcmd $TMPDIR/$BUILDDIR/$PROG --new-config \
        || logerr "Failed to generate config"

    logcmd mkdir -p $DESTDIR/$PREFIX/bin \
        || logerr "Failed to create bin dir"
    logcmd mkdir -p $DESTDIR/etc/$PREFIX \
        || logerr "Failed to create conf dir"

    logcmd cp $TMPDIR/$BUILDDIR/$PROG $DESTDIR/$PREFIX/bin/ \
        || logerr "Failed to install binary"
    logcmd cp $TMPDIR/$BUILDDIR/config.toml $DESTDIR/etc/$PREFIX/ \
        || logerr "Failed to install config"
}

init
clone_go_source $PROG knadh v$VER
patch_source
prep_build
MAKE_TARGET=dist build -noctf
install_smf ooce listmonk.xml
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
