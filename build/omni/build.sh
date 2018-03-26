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
# Copyright 2018 OmniOS Community Edition (OmniOSce) Association.
# Use is subject to license terms.
#
# Load support functions
. ../../lib/functions.sh

PROG=omni
VER=1.2.6
VERHUMAN=$VER
PKG=ooce/developer/omni
SUMMARY="OmniOS build management utility"
DESC=$SUMMARY
PREFIX=/opt/ooce
MIRROR="https://github.com/omniosorg/$PROG/archive"
BUILDDIR="$PROG-$VER"
TAR=gtar
XFORM_ARGS="-D PREFIX=$PREFIX"

build() {
    mkdir -p "$DESTDIR/$PREFIX/$PROG"
    ( cd $TMPDIR/$BUILDDIR; find . | cpio -pvmud "$DESTDIR/$PREFIX/$PROG/" )
    sed -i "/OMNIVER/s/master/$VER/" $DESTDIR/$PREFIX/$PROG/bin/omni
}

init
download_source $VER $VER ""
prep_build
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
