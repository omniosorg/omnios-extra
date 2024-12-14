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

PROG=libmcrypt
VER=2.5.8
PKG=ooce/library/libmcrypt
SUMMARY="Multi-cipher cryptographic library"
DESC="libmcrypt is a cryptographic library that conveniently brings together \
a variety of ciphers for convenient use."

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
"

CONFIGURE_OPTS+="
    --mandir=$PREFIX/share/man
"

pre_configure() {
    typeset arch=$1

    ! cross_arch $arch && return

    CONFIGURE_OPTS[$arch]+="
        ac_cv_func_malloc_0_nonnull=yes
        ac_cv_func_realloc_0_nonnull=yes
    "
}

LDFLAGS[i386]+=" -lssp_ns"

init
download_source $PROG $PROG $VER
patch_source
prep_build
run_autoconf -f
build
run_testsuite check
strip_install
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
