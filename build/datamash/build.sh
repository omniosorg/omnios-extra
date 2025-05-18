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

PROG=datamash
VER=1.8
PKG=ooce/text/datamash
SUMMARY="GNU $PROG"
DESC="A command-line program which performs basic numeric, textual and "
DESC+="statistical operations on input textual data files."

OPREFIX=$PREFIX
PREFIX+=/$PROG

set_arch 64
set_clangver

# the test-suite requires GNU tools and we get all sorts of weird
# test-suite errors if we don't use GNU tools to build as well
export PATH=$GNUBIN:$PATH

XFORM_ARGS="
    -DOPREFIX=${OPREFIX#/}
    -DPREFIX=${PREFIX#/}
    -DPROG=$PROG
    -DPKGROOT=$PROG
"

CONFIGURE_OPTS="--with-openssl"

CPPFLAGS+=" -DOOCEVER=$RELVER"

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
