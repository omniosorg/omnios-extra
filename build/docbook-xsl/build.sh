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

PROG=docbook-xsl
VER=20200603
VERHUMAN=$VER
PKG=ooce/text/docbook-xsl
SUMMARY="XSLT 1.0 Stylesheets for DocBook"
DESC="$PROG - $SUMMARY"

BUILDDIR=docbook-xsl-snapshot

OPREFIX=$PREFIX
PREFIX+="/$PROG"

set_arch 64

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
"

pre_build() {
    typeset arch=$1

    destdir=$DESTDIR
    cross_arch $arch && destdir+=".$arch"

    pushd $TMPDIR/$BUILDDIR >/dev/null
    logcmd $MKDIR -p $destdir/$PREFIX
    $FD . | cpio -pvmud $destdir/$PREFIX >/dev/null
    popd >/dev/null

    false
}

init
prep_build
download_source docbook $PROG $VER
patch_source
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
