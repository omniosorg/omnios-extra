#!/usr/bin/bash
#
# {{{ CDDL HEADER
#
# This file and its contents are supplied under the terms of the
# Common Development and Distribution License ("CDDL"), version 1.0.
# You may only use this file in accordance with the terms of version
# 1.0 of the CDDL.
#
# A full copy of the text of the CDDL should have accompanied this
# source. A copy of the CDDL is also available via the Internet at
# http://www.illumos.org/license/CDDL.
# }}}

# Copyright 2020 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/functions.sh

PROG=mattermost
VER=5.21.0
MMCTLVER=$VER
PKG=ooce/application/mattermost
SUMMARY="$PROG"
DESC="All your team communication in one place, "
DESC+="instantly searchable and accessible anywhere."

set_arch 64
set_gover 1.13

OPREFIX=$PREFIX
PREFIX+="/$PROG"

export BUILD_NUMBER=$VER

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
"

build() {
    pushd $TMPDIR/$BUILDDIR > /dev/null

    logmsg "Building 64-bit"
    logcmd $MAKE "$@" || logerr "Build failed"

    popd >/dev/null
}

install() {
    logcmd mkdir -p $DESTDIR/$OPREFIX || logerr "mkdir"

    logcmd mv $TMPDIR/proto/$PROG $DESTDIR/$OPREFIX \
        || logerr "Cannot move dist to $DESTDIR"

    for f in platform $PROG; do
        logcmd cp $TMPDIR/$BUILDDIR/proto/bin/$f $DESTDIR/$PREFIX/bin \
            || logerr "Cannot copy $f to $DESTDIR"
    done

    logcmd cp $TMPDIR/$BUILDDIR/../mmctl/mmctl $DESTDIR/$PREFIX/bin \
        || logerr "Cannot copy mmctl to $DESTDIR"

    logmsg "Creating config path"
    logcmd mkdir -p $DESTDIR/etc/$PREFIX || logerr "Cannot create config path"
    logcmd mv $DESTDIR/$PREFIX/config/config.json $DESTDIR/etc/$PREFIX \
        || logerr "Cannot move mattermost config"
}

init
prep_build

#########################################################################

# building mmctl
_prog=$PROG
_builddir=$BUILDDIR
PROG=mmctl

clone_go_source $PROG $_prog v$MMCTLVER
build "ADVANCED_VET=FALSE"

BUILDDIR=$_builddir
PROG=$_prog

#########################################################################

BUILDDIR=$PROG download_source $PROG $PROG-team-$VER-linux-amd64 '' $TMPDIR/proto
# use clone_github_source instead of clone_go_source
# since mattermost bundles its dependencies
clone_github_source $PROG "$GITHUB/$PROG/$PROG-server" v$VER
BUILDDIR+=/$PROG
patch_source
export GOPATH="$TMPDIR/$BUILDDIR/proto"
build build-illumos
install
install_smf application $PROG.xml
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
