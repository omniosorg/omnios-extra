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
# Copyright 2017 OmniOS Community Edition (OmniOSce) Association.
# Use is subject to license terms.
#
# Load support functions
. ../../lib/functions.sh

PROG=kvmadm     # App name
VER=0.12.2      # App version
VERHUMAN=$VER   # Human-readable version
PKG=ooce/kvmadm # Package name (e.g. library/foo)
SUMMARY="IPS package management/publishing tool" # One-liner, must be filled in
DESC=$SUMMARY   # Longer description, must be filled in
BUILDARCH=32    # or 64 or both ... for libraries we want both for tools 32 bit only
PREFIX=/opt/ooce
MIRROR="https://github.com/hadfl/$PROG/releases/download"

RUN_DEPENDS_IPS="
    driver/virtualization/kvm
    system/kvm
"

XFORM_ARGS="-D PREFIX=$PREFIX"

CONFIGURE_OPTS_32="
    --prefix=$PREFIX/$PROG
    --localstatedir=/var$PREFIX/$PROG
    --enable-svcinstall=/lib/svc/manifest/ooce/$PROG
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
