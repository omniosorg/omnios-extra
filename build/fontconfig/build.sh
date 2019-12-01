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

PROG=fontconfig
VER=2.13.1
PKG=ooce/library/fontconfig
SUMMARY="$PROG"
DESC="A library for configuring and customizing font access"

SKIP_LICENCES=MIT

OPREFIX=$PREFIX
PREFIX+="/$PROG"

BUILD_DEPENDS_IPS="
    library/expat
    ooce/developer/gperf
    ooce/library/freetype2
"

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
"

CONFIGURE_OPTS="
    --prefix=$PREFIX
    --sysconfdir=/etc$PREFIX
    --includedir=$OPREFIX/include
    --with-cache-dir=/var/$PREFIX/cache
"
CONFIGURE_OPTS_32="
    --bindir=$PREFIX/bin/$ISAPART
    --sbindir=$PREFIX/sbin/$ISAPART
    --libdir=$OPREFIX/lib
"
CONFIGURE_OPTS_64="
    --bindir=$PREFIX/bin
    --sbindir=$PREFIX/sbin
    --libdir=$OPREFIX/lib/$ISAPART64
"

# The build framework expects GNU tools
export PATH="/usr/gnu/bin:$PATH"

save_function configure32 _configure32
configure32() {
    export PKG_CONFIG_PATH="$OPREFIX/lib/pkgconfig"
    _configure32
}

save_function configure64 _configure64
configure64() {
    export PKG_CONFIG_PATH="$OPREFIX/lib/$ISAPART64/pkgconfig"
    _configure64
}

rem_abs_symlinks() {
    logmsg "--- removing absolute symlinks"
    logcmd rm -f $DESTDIR/etc$PREFIX/fonts/conf.d/*.conf
}

LDFLAGS32+=" -L$OPREFIX/lib -R$OPREFIX/lib"
LDFLAGS64+=" -L$OPREFIX/lib/$ISAPART64 -R$OPREFIX/lib/$ISAPART64"

init
download_source $PROG $PROG $VER
prep_build
patch_source
run_autoreconf -fi
build -ctf
rem_abs_symlinks
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
