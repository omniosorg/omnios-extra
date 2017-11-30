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
# Copyright 2017 OmniOS Community Edition (OmniOSce) Association.
# Use is subject to license terms.
#
# Load support functions
. ../../lib/functions.sh

PROG=ooceapps   # App name
VER=0.2.3       # App version
VERHUMAN=$VER   # Human-readable version
#PVER=          # Branch (set in config.sh, override here if needed)
PKG=ooce/ooceapps # Package name (e.g. library/foo)
SUMMARY="Mattermost integrations for OmniOSce" # One-liner, must be filled in
DESC=$SUMMARY   # Longer description, must be filled in
BUILDARCH=64    # or 64 or both ... for libraries we want both for tools 32 bit only
PREFIX=/opt/ooce
MIRROR="https://github.com/omniosorg/$PROG/releases/download"

CONFIGURE_OPTS_64="
    --prefix=$PREFIX/$PROG
    --sysconfdir=/etc$PREFIX/$PROG
    --localstatedir=/var$PREFIX/$PROG"

add_extra_files() {
    logmsg "--- Copying SMF manifest"
    logcmd mkdir -p $DESTDIR/lib/svc/manifest/network
    logcmd cp $SRCDIR/files/ooceapps.xml $DESTDIR/lib/svc/manifest/network
    logcmd mkdir -p $DESTDIR/var/$PREFIX/$PROG
    # copy config template
    logcmd cp $DESTDIR/etc/$PREFIX/$PROG/${PROG}.conf.dist $DESTDIR/etc/$PREFIX/$PROG/${PROG}.conf \
        || logerr "--- cannot copy config file template"
}

init
download_source "v$VER" $PROG $VER
patch_source
prep_build
build
add_extra_files
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
