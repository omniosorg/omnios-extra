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

PROG=tiff
VER=4.6.0
PKG=ooce/library/tiff
SUMMARY="LibTIFF - TIFF Library and Utilities"
DESC="Support for the Tag Image File Format (TIFF), a widely used format "
DESC+="for storing image data."

# Previous versions that also need to be built and packaged since compiled
# software may depend on it.
PVERS="4.4.0"

forgo_isaexec
test_relver '>=' 151045 && set_clangver

export MAKE

SKIP_LICENCES=BSD-like

OPREFIX=$PREFIX
PREFIX+="/$PROG"

TESTSUITE_FILTER='^[A-Z#][A-Z ]'

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
    -DPKGROOT=$PROG
"

CONFIGURE_OPTS+="
    --prefix=$PREFIX
    --bindir=$PREFIX/bin
    --disable-static
"

pre_configure() {
    typeset arch=$1

    LDFLAGS[$arch]+=" -Wl,-R$OPREFIX/${LIBDIRS[$arch]}"
}

init
prep_build

# Skip previous versions for cross compilation
pre_build() { ! cross_arch $1; }

# Build previous versions
for pver in $PVERS; do
    note -n "Building previous version: $pver"
    set_builddir $PROG-$pver
    download_source -dependency $PROG $PROG $pver
    patch_source patches-`echo $pver | cut -d. -f1-2`
    build
done
unset -f pre_build

note -n "Building current version: $VER"

set_builddir $PROG-$VER
download_source $PROG $PROG $VER
patch_source
build
# test-suite requires GNU diff
PATH="$GNUBIN:$PATH" run_testsuite check
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
