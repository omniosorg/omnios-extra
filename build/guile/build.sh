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
#
# Copyright 2019 OmniOS Community Edition (OmniOSce) Association.
#
. ../../lib/functions.sh

PROG=guile
VER=2.0.14
PKG=ooce/library/guile
SUMMARY="GNU Ubiquitous Intelligent Language for Extensions"
DESC="$SUMMARY"

[ $RELVER -lt 151030 ] && exit 0

BUILD_DEPENDS_IPS="ooce/library/unistring ooce/library/bdw-gc"

OPREFIX=$PREFIX
PREFIX+="/$PROG"

XFORM_ARGS="-D OPREFIX=${OPREFIX#/}"

CPPFLAGS+=" -I/usr/include/gmp -I$OPREFIX/include"
LDFLAGS_32+=" -L$OPREFIX/lib -R$OPREFIX/lib"
LDFLAGS_64+=" -L$OPREFIX/lib/amd64 -R$OPREFIX/lib/amd64"
export LDFLAGS="$LDFLAGS_32 -lsocket -lnsl"

export BDW_GC_CFLAGS="-I$OPREFIX/include"
export BDW_GC_LIBS="$LDFLAGS_32 -lgc"

CONFIGURE_OPTS="
    --prefix=$PREFIX
    --includedir=$OPREFIX/include
    --disable-error-on-warning
    ac_cv_type_complex_double=no
"

CONFIGURE_OPTS_32="
    --bindir=$PREFIX/bin/$ISAPART
    --libdir=$OPREFIX/lib
"
CONFIGURE_OPTS_64="
    --bindir=$PREFIX/bin/$ISAPART64
    --libdir=$OPREFIX/lib/$ISAPART64
"

save_function configure64 _configure64
configure64() {
    export BDW_GC_LIBS="$LDFLAGS_64 -lgc"
    export LDFLAGS="$LDFLAGS_64"
    _configure64
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_isa_stub
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
