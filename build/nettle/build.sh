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

PROG=nettle
VER=4.0
PKG=ooce/library/nettle
SUMMARY="$PROG - low-level cryptographic library"
DESC="Cryptographic library that is designed to fit easily in more or "
DESC+="less any context"

# Previous versions that also need to be built and packaged since compiled
# software may depend on it.
PVERS="3.10.2"

forgo_isaexec
# secure_getenv
set_standard XPG8

CONFIGURE_OPTS="
    --disable-static
    --disable-openssl
"
CONFIGURE_OPTS[aarch64]+=" HOST_CC=/opt/gcc-$DEFAULT_GCC_VER/bin/gcc"

CPPFLAGS+=" -I/usr/include/gmp"

pre_configure() {
    typeset arch=$1

    LDFLAGS[$arch]+=" -R$PREFIX/${LIBDIRS[$arch]}"
}

init
prep_build

# Skip previous versions for cross compilation
pre_build() { ! cross_arch $1; }

# Build previous versions
for pver in $PVERS; do
    note -n "Building previous version: $pver"
    set_builddir $PROG-$pver
    download_source -dependency $PROG $PROG $pver
    patch_source patches-`echo $pver | cut -d. -f1-2`
    build
done
unset -f pre_build

note -n "Building current version: $VER"

set_builddir $PROG-$VER
download_source $PROG $PROG $VER
patch_source
build
run_testsuite check
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
