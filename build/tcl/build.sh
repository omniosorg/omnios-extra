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

PROG=tcl
VER=8.6.9
EXPECTVER=5.45.4
PKG=ooce/runtime/tcl
SUMMARY="Tool Command Language"
DESC="A very powerful but easy to learn dynamic programming language"

MAJVER=${VER%.*}

OPREFIX=$PREFIX
PREFIX+=/$PROG

BUILDDIR=$PROG$VER/unix
PATCHDIR+=-$PROG

SKIP_LICENCES=BSD-style

set_arch 64

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
    -DVERSION=$MAJVER
"

CONFIGURE_OPTS_64="
    --prefix=$PREFIX
    --enable-man-symlinks
    --enable-64bit
"

save_function configure64 _configure64
configure64() {
    _configure64

    pushd $TMPDIR/$BUILDDIR/../doc >/dev/null
    for f in *.n ; do
        manbase=`basename "$f" .n`
        mv "$f" "${manbase}.1t"
    done
    for f in *.3 ; do
        manbase=`basename "$f" .3`
        mv "$f" "${manbase}.3tcl"
    done

    popd >/dev/null
}

init
download_source $PROG $PROG$VER-src
patch_source
prep_build
build
strip_install
make_package $PROG-local.mog

#########################################################################
# Expect
#########################################################################

PROG=expect
VER=$EXPECTVER
PKG=ooce/runtime/expect
SUMMARY="Expect"
DESC="A tool for automating interactive applications"

TCLDIR=$DESTDIR$PREFIX/lib
PREFIX="$OPREFIX/$PROG"

BUILDDIR=$PROG$VER
PATCHDIR=patches-$PROG

SKIP_LICENCES=NIST

# pkgdepend fails dependency resulution because TCL is not available, yet
RUN_DEPENDS_IPS="ooce/runtime/tcl"

set_arch 64

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
"

CONFIGURE_OPTS_64="
    --prefix=$PREFIX
    --enable-64bit
    --with-tcl=$TCLDIR
"

save_function _configure64 configure64

init
download_source $PROG $PROG$VER
patch_source
prep_build
LD_LIBRARY_PATH=$TCLDIR build
make_package $PROG-local.mog
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
