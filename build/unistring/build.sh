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
#
# Copyright 2019 OmniOS Community Edition (OmniOSce) Association.
#
. ../../lib/functions.sh

PROG=unistring
VER=0.9.10
PKG=ooce/library/unistring
SUMMARY="Unicode string manipulation library"
DESC="$SUMMARY"
BUILDDIR=lib$PROG-$VER

[ $RELVER -lt 151030 ] && exit 0

CONFIGURE_OPTS="
    --disable-namespacing
"

init
download_source $PROG lib$PROG $VER
patch_source
prep_build
build
make_isa_stub
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
