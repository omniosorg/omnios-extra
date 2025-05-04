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

PROG=tcl
VER=9.0.1
EXPECTVER=5.45.4.1
PKG=ooce/runtime/tcl
SUMMARY="Tool Command Language"
DESC="A very powerful but easy to learn dynamic programming language"

MAJVER=${VER%.*}

OPREFIX=$PREFIX
PREFIX+=/$PROG

set_builddir $PROG$VER
set_patchdir patches-$PROG

SKIP_LICENCES=BSD-style

set_arch 64

# the build requires gnu find
PATH=$GNUBIN:$PATH

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
    -DPKGROOT=$PROG
    -DVERSION=$MAJVER
"

CONFIGURE_OPTS[amd64]="
    --prefix=$PREFIX
    --enable-man-symlinks
    --mandir=$PREFIX/share/man
    --enable-64bit
"

pre_build() {
    append_builddir unix

    unset -f pre_build
}

post_configure() {
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

    unset -f post_configure
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

# does not yet build with gcc 14
((GCCVER > 13)) && set_gccver 13

set_builddir $PROG-$VER
set_patchdir patches-$PROG

SKIP_LICENCES=NIST

# pkgdepend fails dependency resulution because TCL is not available, yet
RUN_DEPENDS_IPS="ooce/runtime/tcl"

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
    -DPKGROOT=$PROG
"

CONFIGURE_OPTS[amd64]="
    --prefix=$PREFIX
    --enable-64bit
    --with-tcl=$TCLDIR
"

init
download_source $PROG $PROG $VER
patch_source
prep_build
run_autoconf -f
LD_LIBRARY_PATH=$TCLDIR build
make_package $PROG-local.mog
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
