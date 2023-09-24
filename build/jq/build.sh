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

PROG=jq
PKG=ooce/util/jq
VER=1.7
SUMMARY="$PROG - JSON query tool"
DESC="$PROG is a lightweight and flexible command-line JSON processor"

OPREFIX=$PREFIX
PREFIX+=/$PROG

BUILD_DEPENDS_IPS="ooce/library/onig"

set_arch 64
test_relver '>=' 151047 && set_clangver

export MAKE

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
    -DVERSION=$VER
"

CONFIGURE_OPTS="
    --prefix=$PREFIX
"

pre_configure() {
    typeset arch=$1

    CONFIGURE_OPTS[$arch]+=" --with-oniguruma=${SYSROOT[$arch]}$OPREFIX"
    LDFLAGS[$arch]="-L${SYSROOT[$arch]}$OPREFIX/${LIBDIRS[$arch]}"
    LDFLAGS[$arch]+=" -Wl,-R$OPREFIX/${LIBDIRS[$arch]}"
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
