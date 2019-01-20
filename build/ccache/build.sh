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
# Copyright 2016-2018 Jim Klimov
# Copyright 2019 OmniOS Community Edition (OmniOSce) Association.
# Use is subject to license terms.
#
. ../../lib/functions.sh

PROG=ccache
VER=3.6
PKG=ooce/developer/ccache
SUMMARY="ccache - cache GCC-compiled files to avoid doing the same job twice"
DESC="$SUMMARY ($VER)"

BUILD_DEPENDS_IPS="developer/build/autoconf text/gnu-grep"

SKIP_LICENCES="Various"

OPREFIX=$PREFIX
PREFIX+="/$PROG"
XFORM_ARGS="
    -DOPREFIX=$OPREFIX
    -DPREFIX=$PREFIX
    -DPROG=$PROG
"

set_arch 64

init
download_source $PROG $PROG $VER
patch_source
run_autoreconf -fi
prep_build
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
