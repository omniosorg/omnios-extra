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

# Copyright 2020 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/functions.sh

PROG=autogen
VER=5.18.16
PKG=ooce/developer/autogen
SUMMARY="Autogen - automated text and program generation tool"
DESC="$SUMMARY"

[ $RELVER -lt 151030 ] && exit 0

BUILD_DEPENDS_IPS="ooce/library/guile"

set_arch 64

# The build framework expects tools like `mktemp` to support GNU
# options.
PATH="/usr/gnu/bin:/opt/ooce/guile/bin:/opt/ooce/bin:$PATH"
export PATH

OPREFIX=$PREFIX
PREFIX+="/$PROG"

XFORM_ARGS="
    -DPROG=$PROG
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
"

CONFIGURE_OPTS="
    --sysconfdir=/etc/$OPREFIX
    --bindir=$PREFIX/bin
    --disable-dependency-tracking
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
