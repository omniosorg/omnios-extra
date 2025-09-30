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

PROG=fontconfig
VER=2.16.0
PKG=ooce/library/fontconfig
SUMMARY="$PROG"
DESC="A library for configuring and customizing font access"

SKIP_LICENCES=MIT
SKIP_RTIME_CHECK=1
SKIP_SSP_CHECK=1

test_relver '>=' 151055 && set_clangver

OPREFIX=$PREFIX
PREFIX+="/$PROG"

forgo_isaexec

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
    -DPKGROOT=$PROG
"

CONFIGURE_OPTS="
    --prefix=$PREFIX
    --sysconfdir=/etc$PREFIX
    --includedir=$OPREFIX/include
    --with-default-fonts=$OPREFIX/share/fonts
    --with-cache-dir=/var/$PREFIX/cache
"

pre_configure() {
    typeset arch=$1

    # The build framework expects GNU tools
    export PATH="$GNUBIN:$PATH"

    CONFIGURE_OPTS[$arch]+="
        --libdir=$OPREFIX/${LIBDIRS[$arch]}
    "

    LDFLAGS[$arch]+=" -L$OPREFIX/${LIBDIRS[$arch]}"
    LDFLAGS[$arch]+=" -R$OPREFIX/${LIBDIRS[$arch]}"
}

post_install() {
    logmsg "--- removing absolute symlinks"
    logcmd $RM -f $DESTDIR/etc$PREFIX/fonts/conf.d/*.conf
}

init
download_source $PROG $PROG $VER
patch_source
prep_build autoconf -autoreconf
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
