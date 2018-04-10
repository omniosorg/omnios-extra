#!/usr/bin/bash
#
#  {{{ CDDL HEADER START
#
# This file and its contents are supplied under the terms of the
# Common Development and Distribution License ("CDDL"), version 1.0.
# You may only use this file in accordance with the terms of version
# 1.0 of the CDDL.
#
# A full copy of the text of the CDDL should have accompanied this
# source. A copy of the CDDL is also available via the Internet at
# http://www.illumos.org/license/CDDL.
#
# CDDL HEADER END  }}}
#
# Copyright 2018 OmniOS Community Edition (OmniOSce) Association.
#
. ../../lib/functions.sh

PROG=openmpi
VER=2.1.3
VERHUMAN=$VER
PKG=ooce/library/openmpi
SUMMARY="Open MPI - A High Performance Message Passing Library"
DESC="$SUMMARY"

BUILD_DEPENDS_IPS="system/library/gfortran-runtime"

OPREFIX=$PREFIX
PREFIX+="/$PROG"
XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
"

CONFIGURE_OPTS="
    --prefix=$PREFIX
    --sysconfdir=/etc$PREFIX
    --includedir=$OPREFIX/include
    --disable-pmix-dstore
    --without-slurm
"
CONFIGURE_OPTS_32="
    --bindir=$PREFIX/bin/$ISAPART
    --sbindir=$PREFIX/sbin/$ISAPART
    --libdir=$OPREFIX/lib
    --libexecdir=$OPREFIX/libexec
"
CONFIGURE_OPTS_64="
    --bindir=$PREFIX/bin/$ISAPART64
    --sbindir=$PREFIX/sbin/$ISAPART64
    --libdir=$OPREFIX/lib/$ISAPART64
    --libexecdir=$OPREFIX/libexec/$ISAPART64
"

save_function configure64 configure64_orig
configure64(){
    export FCFLAGS="-m64 -fdefault-integer-8"
    configure64_orig
}

init
download_source $PROG $PROG $VER
prep_build
build
make_isa_stub
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
