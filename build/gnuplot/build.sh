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

PROG=gnuplot
VER=5.4.10
PKG=ooce/application/gnuplot
SUMMARY="gnuplot"
DESC="A portable command-line driven graphing utility"

SKIP_LICENCES=gnuplot

OPREFIX=$PREFIX
PREFIX+="/$PROG"

set_arch 64
test_relver '>=' 151049 && set_clangver

XFORM_ARGS="
    -DOPREFIX=${OPREFIX#/}
    -DPREFIX=${PREFIX#/}
    -DPROG=$PROG
    -DPKGROOT=$PROG
"

CONFIGURE_OPTS+=" --with-qt=no"

CPPFLAGS+=" -I$OPREFIX/include"
LDFLAGS[amd64]+=" -L$OPREFIX/lib/amd64 -Wl,-R$OPREFIX/lib/amd64"

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
