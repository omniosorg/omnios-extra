#!/usr/bin/bash
#
# {{{ CDDL HEADER START
#
# The contents of this file are subject to the terms of the
# Common Development and Distribution License, Version 1.0 only
# (the "License").  You may not use this file except in compliance
# with the License.
#
# You can obtain a copy of the license at usr/src/OPENSOLARIS.LICENSE
# or http://www.opensolaris.org/os/licensing.
# See the License for the specific language governing permissions
# and limitations under the License.
#
# When distributing Covered Code, include this CDDL HEADER in each
# file and include the License file at usr/src/OPENSOLARIS.LICENSE.
# If applicable, add the following below this CDDL HEADER, with the
# fields enclosed by brackets "[]" replaced with your own identifying
# information: Portions Copyright [yyyy] [name of copyright owner]
#
# CDDL HEADER END }}}
#
# Copyright 2011-2012 OmniTI Computer Consulting, Inc.  All rights reserved.
# Copyright 2018 OmniOS Community Edition (OmniOSce) Association.
# Use is subject to license terms.
#
. ../../lib/functions.sh

PROG=Python
PROGLC=${PROG,,}
VER=3.6.5
VERHUMAN=$VER
PKG=ooce/runtime/python-36
SUMMARY="$PROG - An Interpreted, Interactive, Object-oriented, Extensible Programming Language."
DESC="$SUMMARY"
VERMAJOR=${VER%.*}

BUILD_DEPENDS_IPS="system/library/gcc-5-runtime library/libffi"
RUN_DEPENDS_IPS=$BUILD_DEPENDS_IPS

ORIGPREFIX=$PREFIX
PREFIX=$PREFIX/$PROGLC-$VERMAJOR
BUILDARCH=64

XFORM_ARGS="-D VERMAJOR=$VERMAJOR"

CFLAGS="-O3"
CXXFLAGS="-O3"
CPPFLAGS="-D_REENTRANT"

CONFIGURE_OPTS="
    --enable-shared
    --disable-static
    --with-system-ffi
"

CONFIGURE_OPTS_64="
    --prefix=$PREFIX
    --sysconfdir=/etc/$ORIGPREFIX/$PROGLC$VERMAJOR
    --includedir=$PREFIX/include
    --bindir=$PREFIX/bin
    --sbindir=$PREFIX/sbin
    --libdir=$PREFIX/lib
    --libexecdir=$PREFIX/libexec
"

build() {
    CC="$CC $CFLAGS $CFLAGS64" \
    CXX="$CXX $CXXFLAGS $CXXFLAGS64" \
    build64
    logcmd mv "$DESTDIR/$PREFIX/lib/$PROGLC$VERMAJOR/site-packages/setuptools/script (dev).tmpl" \
        "$DESTDIR/$PREFIX/lib/$PROGLC$VERMAJOR/site-packages/setuptools/script_dev.tmpl"
}

make_install64() {
    logmsg '--- make install'
    logcmd $MAKE DESTDIR=$DESTDIR DESTSHARED=${PREFIX}/lib/$PROGLC${VERMAJOR}/lib-dynload install || \
        logerr '--- make install failed'
}
create_symlinks() {
    logmsg "--- Create bin symlink"
    logcmd mkdir -p $DESTDIR/$ORIGPREFIX/bin
    logcmd ln -s ../$PROGLC-$VERMAJOR/bin/$PROGLC$VERMAJOR $DESTDIR/$ORIGPREFIX/bin/$PROGLC$VERMAJOR
    logcmd ln -s $PROGLC$VERMAJOR $DESTDIR/$ORIGPREFIX/bin/${PROGLC}3
    logmsg "--- Create man symlink"
    logcmd mkdir -p $DESTDIR/$ORIGPREFIX/share/man/man1
    logcmd ln -s ../../../$PROGLC-$VERMAJOR/share/man/man1/$PROGLC${VERMAJOR}.1 \
        $DESTDIR/$ORIGPREFIX/share/man/man1/$PROGLC${VERMAJOR}.1
    logcmd ln -s $PROGLC${VERMAJOR}.1 $DESTDIR/$ORIGPREFIX/share/man/man1/${PROGLC}3.1
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
create_symlinks
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
