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

# The following lines let buildctl spot the packages that are actually built
# by the makefiles in pkg
PKG=package/pkg
PKG=system/zones/brand/ipkg
PKG=system/zones/brand/lipkg
SUMMARY="This isn't used, see the makefiles for pkg"
DESC="This isn't used, see the makefiles for pkg"

PROG=pkg
VER=omni
BUILDNUM=$RELVER
if [ -z "$PKGPUBLISHER" ]; then
    logerr "No PKGPUBLISHER specified. Check lib/site.sh"
    exit
fi

GIT=/usr/bin/git
# On a running system, these are in /usr/include/.
HEADERS="libbrand.h libuutil.h libzonecfg.h"
BRAND_CFLAGS="-I./gate-include"

BUILD_DEPENDS_IPS="developer/versioning/git developer/versioning/mercurial system/zones/internal text/intltool"
DEPENDS_IPS="runtime/python-27"

# Respect environmental overrides for these to ease development.
: ${PKG_SOURCE_REPO:=https://github.com/omniosorg/pkg5}
: ${PKG_SOURCE_BRANCH:=r$RELVER}

clone_source(){
    logmsg "pkg -> $TMPDIR/$BUILDDIR/pkg"
    logcmd mkdir -p $TMPDIR/$BUILDDIR
    pushd $TMPDIR/$BUILDDIR > /dev/null 
    # Even though our default is "pkg5" now, still call the directory 
    # "pkg" for now due to the hideous number of places "pkg" occurs here.
    if [ ! -d pkg ]; then
        if [ -n "$PKG5_CLONE" -a -d "$PKG5_CLONE" ]; then
            logmsg "-- pulling pkg5 from local clone"
            logcmd rsync -ar $PKG5_CLONE/ pkg/
        else
            logcmd $GIT clone $PKG_SOURCE_REPO pkg
        fi
    fi
    if [ -z "$PKG5_CLONE" ]; then
        logcmd $GIT -C pkg pull || logerr "failed to pull"
    fi
    logcmd $GIT -C pkg checkout $PKG_SOURCE_BRANCH \
        || logmsg "No $PKG_SOURCE_BRANCH branch, using master."
    popd > /dev/null 
}

build(){
    pushd $TMPDIR/$BUILDDIR/pkg/src > /dev/null \
        || logerr "Cannot change to src dir"
    find . -depth -name \*.mo -exec touch {} +
    find gui/help -depth -name \*.in | sed -e 's/\.in$//' | xargs touch
    pushd $TMPDIR/$BUILDDIR/pkg/src/brand > /dev/null
    logmsg "--- brand subbuild"
    logcmd make clean
    ISALIST=i386 CC=gcc CFLAGS="$BRAND_CFLAGS" logcmd make \
        CODE_WS=$TMPDIR/$BUILDDIR/pkg || logerr "brand make failed"
    popd
    logmsg "--- toplevel build"
    logcmd make clean
    ISALIST=i386 CC=gcc logcmd make \
        CODE_WS=$TMPDIR/$BUILDDIR/pkg || logerr "toplevel make failed"
    logmsg "--- proto install"
    ISALIST=i386 CC=gcc logcmd make install \
        CODE_WS=$TMPDIR/$BUILDDIR/pkg || logerr "proto install failed"
    popd > /dev/null
}

package(){
    pushd $TMPDIR/$BUILDDIR/pkg/src/pkg > /dev/null
    logmsg "--- packaging"
    logcmd make clean
    ISALIST=i386 CC=gcc logcmd make \
        CODE_WS=$TMPDIR/$BUILDDIR/pkg \
        BUILDNUM=$BUILDNUM || logerr "pkg make failed"
    ISALIST=i386 CC=gcc logcmd make publish-pkgs \
        CODE_WS=$TMPDIR/$BUILDDIR/pkg \
        BUILDNUM=$BUILDNUM \
        PKGSEND_OPTS="" \
        PKGPUBLISHER=$PKGPUBLISHER \
        PKGREPOTGT="" \
        PKGREPOLOC="$PKGSRVR" \
        || logerr "publish failed"
    popd > /dev/null
}

init
clone_source
build
package

# Vim hints
# vim:ts=4:sw=4:et:
