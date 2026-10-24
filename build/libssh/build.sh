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

# Copyright 2026 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=libssh2
VER=1.11.1
PKG=ooce/library/libssh2
SUMMARY="libssh2"
DESC="A client-side C library implementing the SSH2 protocol"

CONFIGURE_OPTS="
    --disable-static
    --with-crypto=openssl
    --with-libz
    --disable-examples-build
    --disable-docker-tests
    --disable-sshd-tests
"

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
