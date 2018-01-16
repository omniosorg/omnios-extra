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
# Copyright 2011-2013 OmniTI Computer Consulting, Inc.  All rights reserved.
# Copyright 2018 OmniOS Community Edition (OmniOSce) Association.
# Use is subject to license terms.
#
# Load support functions
. ../../lib/functions.sh

PROG=joe
VER=4.6
VERHUMAN=$VER
PKG=ooce/editor/joe
SUMMARY="joe's own editor"
DESC="full featured terminal-based screen editor"
CONFPATH=/etc$PREFIX
ORIGPREFIX=$PREFIX
PREFIX=$PREFIX/$PROG
BUILDARCH=64

CONFIGURE_OPTS_64=" \
    --prefix=$PREFIX \
    --sysconfdir=$CONFPATH \
"

create_symlinks() {
    # create symbolic link to standard bin dir
    logcmd mkdir -p $DESTDIR/$ORIGPREFIX/bin
    for P in jmacs  joe    jpico  jstar; do
	logcmd ln -s ../$PROG/bin/$P $DESTDIR/$ORIGPREFIX/bin \
        	|| logerr "--- cannot create $PROG symlink"
    done
    # create symbolic link to man page
    logcmd mkdir -p $DESTDIR/$ORIGPREFIX/share/man/man1
    logcmd ln -s ../../../$PROG/share/man/man1/${PROG}.1 $DESTDIR/$ORIGPREFIX/share/man/man1/${PROG}.1 \
        || logerr "--- cannot create man page symlink"
}


init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_isa_stub
create_symlinks
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
