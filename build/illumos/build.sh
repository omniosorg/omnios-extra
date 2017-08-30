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

    # Before, we used to just send out the non-DEBUG illumos packages.
    #logcmd pkgrecv -s packages/i386/nightly-nd/repo.redist/ -d $PKGSRVR 'pkg:/*'
    # NOW, however, we use pkgmerge to set pkg(5) variants for non-DEBUG *and*
    # DEBUG.  The idea is, if someone wants to shift their illumos from
    # non-DEBUG (default) to DEBUG, they can simply utter:
    #
    #      pkg change-variant debug.illumos=true
    #
    # and a new BE with DEBUG bits appears.

    [ -d $TMPDIR/$BUILDDIR ] || mkdir -p $TMPDIR/$BUILDDIR
    STAGE_REPO=$TMPDIR/$BUILDDIR
    [ -d $STAGE_REPO ] && rm -rf $STAGE_REPO
    logmsg "Creating staging repo at $STAGE_REPO"
    pkgrepo create $STAGE_REPO || logerr "Could not create staging repo"
    pkgrepo add-publisher -s $STAGE_REPO $PKGPUBLISHER || \
	logerr "Could not set publisher on staging repo"

    logmsg "Staging illumos packages to $STAGE_REPO"
    logcmd pkgmerge -d $STAGE_REPO \
	-s debug.illumos=false,packages/i386/nightly-nd/repo.redist/ \
	-s debug.illumos=true,packages/i386/nightly/repo.redist/ \
	$FLAVOR

    logmsg "Staging repository information"
    pkgrepo -s $STAGE_REPO info
    pkgrepo -s $STAGE_REPO list | sed 1d | awk '{print $2}' > $SRCDIR/pkg.list

    republish_packages $STAGE_REPO

    logmsg "Leaving $CODEMGR_WS"
    popd > /dev/null
}

init
prep_build
if [ -d ${PREBUILT_ILLUMOS:-/dev/null} ]; then
    wait_for_prebuilt
    # Check for existing packages, or for freshly built ones if we pwaited.
    if [ -d $PREBUILT_ILLUMOS/packages/i386/nightly-nd/repo.redist ]; then
        logmsg "Using illumos-omnios pre-compiled at $PREBUILT_ILLUMOS"
        CODEMGR_WS=$PREBUILT_ILLUMOS
        push_pkgs
    else
        logmsg "No $PREBUILT_ILLUMOS/packages/i386/nightly-nd/repo.redist"
        if [[ -z $BATCH ]]; then
            ask_to_continue
        fi
    fi
else
    logerr "No prebuilt-illumos defined, check site.sh"
fi
clean_up
