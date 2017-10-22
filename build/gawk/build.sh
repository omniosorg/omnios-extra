#!/usr/bin/bash
#
# CDDL HEADER START
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
# CDDL HEADER END
#
#
# Copyright 2011-2015 OmniTI Computer Consulting, Inc.  All rights reserved.
# Copyright 2017 OmniOS Community Edition (OmniOSce) Association.
# Use is subject to license terms.
#
# Load support functions
. ../../lib/functions.sh

PROG=gawk
VER=4.1.4
VERHUMAN=$VER
PKG=text/gawk
SUMMARY="gawk - GNU implementation of awk"
DESC="$SUMMARY"

BUILDARCH=32
CONFIGURE_OPTS_32+=" --bindir=/usr/bin"
# Use old gcc4 standards level for this.
CFLAGS="$CFLAGS -std=gnu89"

# as of 4.1, gawk now supports arbitrary precision numbers.
# build in MPFR/GMP support rather than dynamically linking it.
save_function configure32 configure32_orig
configure32() {
    configure32_orig

    logmsg "Patching Makefile to make mpfr/gmp static"
    pushd $TMPDIR/$BUILDDIR > /dev/null
    logcmd gsed -i -e \
        "s#-lmpfr -lgmp#$GCCPATH/lib/libmpfr.a $GCCPATH/lib/libgmp.a#" Makefile
    popd > /dev/null
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
run_testsuite check
make_isa_stub
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
