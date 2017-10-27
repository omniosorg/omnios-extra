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
# Copyright 2011-2012 OmniTI Computer Consulting, Inc.  All rights reserved.
# Use is subject to license terms.
#
# Load support functions
. ../../lib/functions.sh

PROG=wget       # App name
VER=1.19.2      # App version
VERHUMAN=$VER   # Human-readable version
PKG=web/wget    # Package name (without prefix)
SUMMARY="$PROG - a utility to retrieve files from the World Wide Web"
DESC="$SUMMARY"

BUILD_DEPENDS_IPS="developer/lexer/flex"
DEPENDS_IPS="library/libidn web/ca-bundle"

BUILDARCH=32
CONFIGURE_OPTS="
    --with-ssl=openssl
    --mandir=$PREFIX/share/man
    POD2MAN=/usr/perl5/bin/pod2man
"

TESTSUITE_FILTER='^[A-Z#][A-Z ]'
[ -n "$BATCH" ] && SKIP_TESTSUITE=1

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
