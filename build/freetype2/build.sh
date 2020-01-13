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

# Copyright 2011-2012 OmniTI Computer Consulting, Inc.  All rights reserved.
# Copyright 2020 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/functions.sh

PROG=freetype
VER=2.10.1
PKG=ooce/library/freetype2
SUMMARY="A Free, High-Quality, and Portable Font Engine"
DESC="$SUMMARY"

# we don't want freetype2 to have any runtime dependencies
# on omnios-extra packages. since openjdk bundles freetype2 and
# therefore would end up having runtime dependencies on -extra packages
PKG_CONFIG_PATH32=
PKG_CONFIG_PATH64=

XFORM_ARGS="-DPREFIX=${PREFIX#/}"

CONFIGURE_OPTS="
    --prefix=$PREFIX
    --includedir=$PREFIX/include
    --disable-static
"

CONFIGURE_OPTS_32="
    --bindir=$PREFIX/bin/$ISAPART
    --libdir=$PREFIX/lib
"
CONFIGURE_OPTS_64="
    --bindir=$PREFIX/bin
    --libdir=$PREFIX/lib/$ISAPART64
"

init
download_source ${PROG}2 $PROG $VER
patch_source
prep_build
build -ctf
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
