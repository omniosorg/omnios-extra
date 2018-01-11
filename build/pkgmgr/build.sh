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

PROG=pkgmgr
VER=0.2.3
VERHUMAN=$VER
PKG=ooce/developer/pkgmgr
SUMMARY="IPS package management/publishing tool"
DESC=$SUMMARY
BUILDARCH=32
MIRROR="https://github.com/omniosorg/$PROG/releases/download"

RUN_DEPENDS_IPS="network/rsync"

CONFIGURE_OPTS_32="
    --prefix=$PREFIX/$PROG
    --sysconfdir=/etc$PREFIX/$PROG
"

add_extra_files() {
    # create symbolic link to standard bin dir
    logcmd mkdir -p $DESTDIR/$PREFIX/bin
    logcmd ln -s ../$PROG/bin/$PROG $DESTDIR/$PREFIX/bin/$PROG \
        || logerr "--- cannot create $PROG symlink"
    # create symbolic link to man page
    logcmd mkdir -p $DESTDIR/$PREFIX/share/man/man1
    logcmd ln -s ../../../$PROG/share/man/man1/${PROG}.1 $DESTDIR/$PREFIX/share/man/man1/${PROG}.1 \
        || logerr "--- cannot create man page symlink"
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
# vim:ts=4:sw=4:et:fdm=marker
