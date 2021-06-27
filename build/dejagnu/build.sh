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

# Copyright 2021 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/functions.sh

PROG=dejagnu
VER=1.6.3
PKG=ooce/developer/dejagnu
SUMMARY="DejaGnu"
DESC="DejaGnu is a framework for testing other programs"

[ $RELVER -lt 151030 ] && exit 0

BUILD_DEPENDS_IPS="ooce/runtime/expect"
RUN_DEPENDS_IPS="$BUILD_DEPENDS_IPS"

OPREFIX=$PREFIX
PREFIX+="/$PROG"

set_arch 64

XFORM_ARGS="
    -DOPREFIX=${OPREFIX#/}
    -DPREFIX=${PREFIX#/}
    -DPROG=$PROG
    -DPKGROOT=$PROG
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
