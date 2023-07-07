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

PROG=fontconfig
VER=2.14.2
PKG=ooce/library/fontconfig
SUMMARY="$PROG"
DESC="A library for configuring and customizing font access"

SKIP_LICENCES=MIT
SKIP_RTIME_CHECK=1
SKIP_SSP_CHECK=1

OPREFIX=$PREFIX
PREFIX+="/$PROG"

BUILD_DEPENDS_IPS="
    library/expat
    ooce/developer/gperf
    ooce/library/freetype2
"

RUN_DEPENDS_IPS="ooce/fonts/liberation"

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
"

CONFIGURE_OPTS="
    --prefix=$PREFIX
    --sysconfdir=/etc$PREFIX
    --includedir=$OPREFIX/include
    --with-default-fonts=$OPREFIX/share/fonts
    --with-cache-dir=/var/$PREFIX/cache
"
CONFIGURE_OPTS[i386]="
    --bindir=$PREFIX/bin/i386
    --sbindir=$PREFIX/sbin/i386
    --libdir=$OPREFIX/lib
"
CONFIGURE_OPTS[amd64]="
    --bindir=$PREFIX/bin
    --sbindir=$PREFIX/sbin
    --libdir=$OPREFIX/lib/amd64
"
CONFIGURE_OPTS[aarch64]+="
    --bindir=$PREFIX/bin
    --sbindir=$PREFIX/sbin
    --libdir=$OPREFIX/lib
"

pre_configure() {
    # The build framework expects GNU tools
    export PATH="$GNUBIN:$PATH"
}

post_install() {
    logmsg "--- removing absolute symlinks"
    logcmd rm -f $DESTDIR/etc$PREFIX/fonts/conf.d/*.conf
}

LDFLAGS[i386]+=" -L$OPREFIX/lib -R$OPREFIX/lib"
LDFLAGS[amd64]+=" -L$OPREFIX/lib/amd64 -R$OPREFIX/lib/amd64"
LDFLAGS[aarch64]+=" -L$OPREFIX/lib -R$OPREFIX/lib"

init
download_source $PROG $PROG $VER
prep_build
patch_source
run_autoreconf -fi
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
