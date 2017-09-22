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

PROG=omnios    # App name
VER=$RELVER    # App version
PVER=1         # Package Version (numeric only)

PKG=illumos-gate # Package name (without prefix)
SUMMARY="$PROG" # A short summary of what the app is, starting with its name
DESC="$SUMMARY -- Illumos and some special sauce." # Longer description

BUILD_DEPENDS_IPS="developer/illumos-tools"

PKGPREFIX=""
PREFIX=""
BUILDDIR=$USER-$PROG-$VER

push_pkgs() {
    logmsg "Entering $CODEMGR_WS"
    pushd $CODEMGR_WS > /dev/null
    logmsg "Pushing illumos pkgs to $PKGSRVR..."
    if [[ -z $BATCH ]]; then
        logmsg "Intentional pause: Last chance to sanity-check before publication!"
        ask_to_continue
    fi

    # Use pkgmerge to set pkg(5) variants for non-DEBUG and DEBUG.
    # The idea is, if someone wants to shift their illumos from
    # non-DEBUG (default) to DEBUG, they can simply utter:
    #
    #      pkg change-variant debug.illumos=true
    #
    # and a new BE with DEBUG bits appears.

    # A particular package or pattern can be specified using the -f argument
    # to this build script which sets $FLAVOR

    ndrepo=packages/i386/nightly-nd/repo.redist
    drepo=packages/i386/nightly/repo.redist

    logmsg "Repository information"
    pkgrepo -s $ndrepo info
    echo

    pkgmerge -d $PKGSRVR \
	-s debug.illumos=false,$ndrepo/ \
	-s debug.illumos=true,$drepo/ \
	$FLAVOR

    logmsg "Leaving $CODEMGR_WS"
    popd > /dev/null
}

init
prep_build
check_for_prebuilt 'packages/i386/nightly-nd/repo.redist/'
CODEMGR_WS=$PREBUILT_ILLUMOS
push_pkgs
clean_up
