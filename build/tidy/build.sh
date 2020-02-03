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

# Copyright 2019 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/functions.sh

PROG=tidy
VER=5.6.0
PKG=ooce/application/tidy
SUMMARY="tidy"
DESC="Application that corrects and cleans up HTML and XML documents by "
DESC+="fixing markup errors and upgrading legacy code to modern standards"

BUILD_DEPENDS_IPS="
    ooce/developer/cmake
"

SKIP_LICENCES=W3C

set_builddir "$PROG-html5-$VER"

CONFIGURE_OPTS="
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_INSTALL_PREFIX=$PREFIX
"
CONFIGURE_OPTS_32="
    -DLIB_INSTALL_DIR=$PREFIX/lib
"
CONFIGURE_OPTS_64="
    -DLIB_INSTALL_DIR=$PREFIX/lib/$ISAPART64
"

LDFLAGS32+=" -R$PREFIX/lib"
LDFLAGS64+=" -R$PREFIX/lib/$ISAPART64"

init
download_source $PROG $VER
patch_source
prep_build cmake
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
