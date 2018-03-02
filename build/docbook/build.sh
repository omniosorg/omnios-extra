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

# Copyright 2018 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/functions.sh

PROG=docbook-xsl
VER=20161215
VERHUMAN=$VER
PKG=ooce/text/docbook-xsl
SUMMARY="XSLT 1.0 Stylesheets for DocBook"
DESC="$SUMMARY"

BUILDDIR=docbook-xsl-snapshot

OPREFIX=$PREFIX
PREFIX+="/$PROG"

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
"

install() {
    pushd $TMPDIR/$BUILDDIR
    logcmd mkdir -p $DESTDIR/$PREFIX
    find . | cpio -pvmud $DESTDIR/$PREFIX >/dev/null
    popd
}

init
prep_build
download_source docbook $PROG $VER
patch_source
install
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
