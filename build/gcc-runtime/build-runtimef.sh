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

# Copyright 2018 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/functions.sh

PKG=system/library/gfortran-runtime
PROG=gfortran
VER=7
VERHUMAN=$VER
SUMMARY="GNU fortran runtime dependencies"
DESC="$SUMMARY"

OPT=/opt/gcc-$VER
LOPT=/opt/gcc-6

init
prep_build

mkdir -p $DESTDIR/usr/lib
mkdir -p $DESTDIR/usr/lib/amd64

##################################################################
LIB=libgfortran.so
LIBVER=4.0.0
XFORM_ARGS+=" -DLIB=$LIB -DLIBVER=$LIBVER"

# Copy in legacy library versions

for v in 3.0.0; do
    if [ -f /usr/lib/$LIB.$v ]; then
        cp /usr/lib/$LIB.$v $DESTDIR/usr/lib/$LIB.$v
    elif [ -f $LOPT/lib/$LIB.$v ]; then
        cp $LOPT/lib/$LIB.$v $DESTDIR/usr/lib/$LIB.$v
    else
        logerr "/usr/lib/$LIB.$v not found"
    fi

    if [ -f /usr/lib/amd64/$LIB.$v ]; then
        cp /usr/lib/amd64/$LIB.$v $DESTDIR/usr/lib/amd64/$LIB.$v
    elif [ -f $LOPT/lib/amd64/$LIB.$v ]; then
        cp $LOPT/lib/amd64/$LIB.$v $DESTDIR/usr/lib/amd64/$LIB.$v
    else
        logerr "/usr/lib/amd64/$LIB.$v not found"
    fi
done

# and current version
cp $OPT/lib/$LIB.$LIBVER $DESTDIR/usr/lib/$LIB.$LIBVER \
    || logerr "Failed to copy $LIBVER"
cp $OPT/lib/amd64/$LIB.$LIBVER $DESTDIR/usr/lib/amd64/$LIB.$LIBVER \
    || logerr "Failed to copy $LIBVER (amd64)"

# libquadmath
LIB=libquadmath.so
LIBVER=0.0.0

cp $OPT/lib/$LIB.$LIBVER $DESTDIR/usr/lib/$LIB.$LIBVER \
    || logerr "Failed to copy $LIBVER"
cp $OPT/lib/amd64/$LIB.$LIBVER $DESTDIR/usr/lib/amd64/$LIB.$LIBVER \
    || logerr "Failed to copy $LIBVER (amd64)"

make_package runtimef.mog runtimef_post.mog
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
