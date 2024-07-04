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

# Copyright 2024 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=nettle
VER=3.10
PKG=ooce/library/nettle
SUMMARY="$PROG - low-level cryptographic library"
DESC="Cryptographic library that is designed to fit easily in more or "
DESC+="less any context"

forgo_isaexec

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
download_source $PROG $PROG $VER
patch_source
prep_build
build
run_testsuite check
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
