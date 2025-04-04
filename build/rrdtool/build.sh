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

PROG=rrdtool
VER=1.9.0
PKG=ooce/database/rrdtool
SUMMARY="Round-Robin Database Tool"
DESC="High performance data logging and graphing system for time series data."

OPREFIX=$PREFIX
PREFIX+="/$PROG"

set_arch 64

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
    -DPKGROOT=$PROG
"

CONFIGURE_OPTS="
    --with-rrd-default-font=LiberationMono-Regular
    --disable-ruby
"
CONFIGURE_OPTS[amd64]+="
    --libdir=$PREFIX/lib
    --with-tcllib=$OPREFIX/tcl/lib
"

LDFLAGS[amd64]+=" -R$OPREFIX/lib/amd64"

export PYTHON

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
strip_install
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
