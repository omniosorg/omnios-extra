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
# Copyright 2017 OmniTI Computer Consulting, Inc.  All rights reserved.
# Copyright 2017 OmniOS Community Edition (OmniOSce) Association.
# Use is subject to license terms.
#
# Load support functions
. ../../lib/functions.sh

PROG=coreutils          # App name
VER=8.28                # App version
PKG=file/gnu-coreutils  # Package name (without prefix)
SUMMARY="coreutils - GNU core utilities"
DESC="GNU core utilities ($VER)"

BUILD_DEPENDS_IPS="compress/xz library/gmp"

CPPFLAGS="-I/usr/include/gmp"
PREFIX=/usr/gnu
reset_configure_opts
CONFIGURE_OPTS+=" --with-openssl=auto"
CONFIGURE_OPTS_32+=" --libexecdir=/usr/lib --bindir=/usr/gnu/bin"
CONFIGURE_OPTS_64+=" --libexecdir=/usr/lib/$ISAPART64"

# coreutils incorrectly detects inotify support
export ac_cv_func_inotify_init=no
# OS as reported by `uname -o`
export gl_cv_host_operating_system=illumos

TESTSUITE_FILTER='^[A-Z#][A-Z ]'
[ -n "$BATCH" ] && SKIP_TESTSUITE=1

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
run_testsuite check
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
