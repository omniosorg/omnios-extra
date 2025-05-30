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

# Copyright 2025 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=xmlto
VER=0.0.29
PKG=ooce/util/xmlto
SUMMARY="$PROG"
DESC="A simple shell script for converting XML files to various formats"

OPREFIX=$PREFIX
PREFIX+=/$PROG

set_arch 64
set_clangver

PATH=$GNUBIN:$PATH
GETOPT=$OPREFIX/bin/getopt
FIND=$GNUBIN/find
MKTEMP=$GNUBIN/mktemp
XML_CATALOG_FILES=$OPREFIX/docbook-xsl/catalog.xml
export PATH GETOPT FIND MKTEMP XML_CATALOG_FILES

RUN_DEPENDS_IPS="
    ooce/text/docbook-xsl
    ooce/util/getopt
"

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
    -DPKGROOT=$PROG
"

init
download_source $PROG $PROG $VER
patch_source
prep_build autoconf -autoreconf
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
