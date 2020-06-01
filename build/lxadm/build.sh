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
. ../../lib/functions.sh

PROG=lxadm      # App name
VER=0.1.6      # App version
VERHUMAN=$VER   # Human-readable version
PKG=ooce/lxadm  # Package name (e.g. library/foo)
SUMMARY="Manage illumos LX zones" # One-liner, must be filled in
DESC=$SUMMARY   # Longer description, must be filled in
BUILDARCH=32    # or 64 or both ... for libraries we want both for tools 32 bit only
PREFIX=/opt/ooce

set_mirror "$GITHUB/hadfl/$PROG/releases/download"
set_checksum sha256 \
    9dd4f70767dd3d04e1df9b45e931cd71cb9868da3f7532395244ad23e2993dc4

RUN_DEPENDS_IPS="system/zones/brand/lx"

XFORM_ARGS="-D PREFIX=${PREFIX#/}"

CONFIGURE_OPTS_32="
    --prefix=$PREFIX/$PROG
    --localstatedir=/var$PREFIX/$PROG
"

init
download_source "v$VER" $PROG $VER
patch_source
prep_build
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
