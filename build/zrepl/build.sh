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

# Copyright 2019 OmniOS Community Edition.  All rights reserved.

. ../../lib/functions.sh

PROG=zrepl
PKG=ooce/system/zrepl
VER=0.2.1
SUMMARY="$PROG - ZFS replication"
DESC="$PROG is a one-stop, integrated solution for ZFS replication"

OPREFIX=$PREFIX
PREFIX+=/$PROG

set_arch 64
set_gover 1.13

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
    -DVERSION=$VER
"

GOOS=illumos
GOARCH=amd64
export GOOS GOARCH

build() {
    pushd $TMPDIR/$BUILDDIR >/dev/null

    export GO111MODULE=on
    export GOPATH=$TMPDIR/go
    logcmd mkdir -p $GOPATH/bin
    export PATH+=":$GOPATH/bin"

    logmsg "--- Building pre-requisites..."
    grep 'go build.*mod=' lazy.sh | while read x x x x x out src; do
        out=${out#*/}
        out=${out//\"}
        logmsg "---- $out"
        logcmd go build -v -mod=readonly -o "$GOPATH/$out" $src
    done
    logmsg "Building zrepl..."
    logcmd $MAKE $PROG-bin ZREPL_VERSION=$VER

    popd >/dev/null
}

install() {
    logcmd mkdir -p $DESTDIR/$PREFIX/bin || logerr "mkdir"
    logcmd cp $TMPDIR/$BUILDDIR/artifacts/$PROG-$GOOS-$GOARCH $DESTDIR/$PREFIX/bin/$PROG \
        || logerr "Cannot install binary"
}

init
download_source $PROG v$VER ""
patch_source
prep_build
build
install
install_smf system zrepl.xml zrepl
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
