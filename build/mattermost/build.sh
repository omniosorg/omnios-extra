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

# Copyright 2019 OmniOS Community Edition (OmniOSce) Association.
#
. ../../lib/functions.sh

PROG=mattermost
VER=5.12.0
VERHUMAN=$VER
PKG=ooce/application/mattermost
SUMMARY="$PROG"
DESC="All your team communication in one place, "
DESC+="instantly searchable and accessible anywhere."

PROGB=$PROG-server
GITHUB=https://github.com/$PROG

set_arch 64
set_gover 1.12

OPREFIX=$PREFIX
PREFIX+="/$PROG"

BUILDDIR="$PROG/src/github.com/$PROG/$PROGB"
GOPATH=$TMPDIR/$PROG-$VER/$PROG
BUILD_NUMBER=$VER
export GOPATH BUILD_NUMBER

BUILD_DEPENDS_IPS="developer/versioning/git"

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
"

# Respect environmental overrides for these to ease development.
: ${MM_SOURCE_REPO:=$GITHUB/$PROGB}
: ${MM_SOURCE_BRANCH:=v$VER}

clone_source() {
    clone_github_source $PROGB \
        "$MM_SOURCE_REPO" "$MM_SOURCE_BRANCH"
}

configure64() { :; }

make_prog64() {
    logmsg "Making $PROG"
    cd $TMPDIR/$BUILDDIR
    $MAKE build-illumos || logerr "Build failed"

}

make_install64() {
    logcmd mkdir -p $DESTDIR/$OPREFIX
    logcmd mv $TMPDIR/proto/$PROG $DESTDIR/$OPREFIX \
        || logerr "Cannot move dist to $DESTDIR"
    for f in platform $PROG; do
        logcmd cp $TMPDIR/$PROG/bin/$f $DESTDIR/$PREFIX/bin \
            || logerr "Cannot copy $f to $DESTDIR"
    done

    logmsg "Creating config path"
    logcmd mkdir -p $DESTDIR/etc/$PREFIX || logerr "Cannot create config path"
    logcmd mv $DESTDIR/$PREFIX/config/config.json $DESTDIR/etc/$PREFIX \
        || logerr "Cannot move mattermost config"
}

init
BUILDDIR=$PROG download_source $PROG $PROG-team-$VER-linux-amd64 '' $TMPDIR/proto
BUILDDIR=$PROG/src/github.com/$PROG clone_source
patch_source
prep_build
build
install_smf application $PROG.xml
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
