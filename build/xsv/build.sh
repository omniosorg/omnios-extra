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

PROG=xsv
VER=0.13.0
PKG=ooce/text/xsv
SUMMARY="$PROG"
DESC="xsv is a command line program for indexing, slicing, analyzing, "
DESC+="splitting and joining CSV files."

BUILD_DEPENDS_IPS=ooce/developer/rust

set_arch 64

# https://www.illumos.org/issues/14659
[ $RELVER -lt 151043 ] && STRIP=gstrip

init
download_source $PROG $VER
patch_source
prep_build
build_rust
install_rust
strip_install
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
