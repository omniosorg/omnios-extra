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
# Copyright 2017 OmniOS Community Edition (OmniOSce) Association.
# Use is subject to license terms.
#
# Load support functions
. ../../lib/functions.sh

PKG=system/library/gcc-runtime
PROG=libgcc_s
VER=7
VERHUMAN=$VER
SUMMARY="gcc runtime"
DESC="$SUMMARY"

init
prep_build

mkdir -p $TMPDIR/$BUILDDIR
for lic in COPYING.RUNTIME COPYING.LIB COPYING3.LIB; do
    logcmd cp $SRCDIR/files/$lic $TMPDIR/$BUILDDIR/$lic || \
        logerr "Cannot copy licence: $lic"
done

mkdir -p $DESTDIR/usr/lib
mkdir -p $DESTDIR/usr/lib/amd64

cp /opt/gcc-$VER/lib/libgcc_s.so.1  $DESTDIR/usr/lib/libgcc_s.so.1
cp /opt/gcc-$VER/lib/amd64/libgcc_s.so.1 $DESTDIR/usr/lib/amd64/libgcc_s.so.1

make_package runtime.mog
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
