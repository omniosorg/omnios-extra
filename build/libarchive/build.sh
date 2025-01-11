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

PROG=libarchive
VER=3.7.7
PKG=ooce/library/libarchive
SUMMARY="libarchive"
DESC="Multi-format archive and compression library"

OPREFIX=$PREFIX
PREFIX+="/$PROG"

forgo_isaexec
set_clangver

SKIP_LICENCES=various

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
    -DPKGROOT=$PROG
"

TESTSUITE_SED="/libtool/d"

CONFIGURE_OPTS+="
    --disable-static
"

pre_configure() {
    typeset arch=$1

    CONFIGURE_OPTS[$arch]+=" --libdir=$OPREFIX/${LIBDIRS[$arch]}"
    LDFLAGS[$arch]+=" -Wl,-R$OPREFIX/${LIBDIRS[$arch]}"
}

init
download_source $PROG $PROG $VER
prep_build
patch_source
build
run_testsuite check
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
