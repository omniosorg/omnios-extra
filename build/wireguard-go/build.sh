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

PROG=wireguard-go
PKG=ooce/network/wireguard-go
VER=0.0.20220316
HASH=c8619d9
SUMMARY="Go Implementation of WireGuard"
DESC="This is an implementation of WireGuard in Go."

RUN_DEPENDS_IPS="driver/tuntap"

set_arch 64
set_gover

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
"

build_and_install() {
    pushd $TMPDIR/$BUILDDIR > /dev/null
    logcmd $MAKE PREFIX=$PREFIX DESTDIR=$DESTDIR install \
        || logerr "Unable to build wireguard-go"
    popd >/dev/null
}

init
# Use nshalman fork until it is fully upstreamed
clone_go_source $PROG nshalman $HASH
prep_build
build_and_install
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
