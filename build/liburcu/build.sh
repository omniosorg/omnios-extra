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

PROG=liburcu
VER=0.15.2
PKG=ooce/library/liburcu
SUMMARY="Userspace RCU"
DESC="Userspace RCU (read-copy-update) library. This data synchronization "
DESC+="library provides read-side access which scales linearly with the "
DESC+="number of cores."

set_clangver

set_builddir userspace-rcu-$VER

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
"

# configure complains about make not being GNU make
export MAKE

CONFIGURE_OPTS="--disable-static"

pre_configure() {
    typeset arch=$1

    LDFLAGS[$arch]+=" -Wl,-R$PREFIX/${LIBDIRS[$arch]}"
}

CFLAGS[aarch64]+=" -mtls-dialect=trad"

init
download_source $PROG userspace-rcu $VER
patch_source
prep_build
build
run_testsuite check
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
