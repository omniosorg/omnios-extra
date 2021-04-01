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

# Copyright 2021 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/functions.sh

PROG=mattermost
VER=5.33.3
MMCTLVER=5.33.0
PKG=ooce/application/mattermost
SUMMARY="$PROG"
DESC="All your team communication in one place, "
DESC+="instantly searchable and accessible anywhere."

set_arch 64
set_gover 1.16
set_nodever 12

BUILD_DEPENDS_IPS="
    ooce/library/libpng
"

OPREFIX=$PREFIX
PREFIX+="/$PROG"

export BUILD_NUMBER=$VER
export PKG_CONFIG_PATH=$PKG_CONFIG_PATH64
export PATH="$GNUBIN:$PATH"

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
"

build() {
    prog="$1"; shift

    note -n "Building $prog"

    PATCHDIR=patches-$prog BUILDDIR+=/$prog patch_source

    pushd $TMPDIR/$BUILDDIR/$prog > /dev/null
    logcmd $MAKE "$@" || logerr "Build failed"
    popd >/dev/null
}

install() {
    logcmd mkdir -p $DESTDIR/$OPREFIX || logerr "mkdir"

    logcmd rsync -a $TMPDIR/$BUILDDIR/$PROG-server/dist/$PROG \
        $DESTDIR/$OPREFIX/ || logerr "copying dist"

    logcmd cp $TMPDIR/$BUILDDIR/mmctl/mmctl $DESTDIR/$PREFIX/bin \
        || logerr "copying mmctl"

    logmsg "Creating config path"
    logcmd mkdir -p $DESTDIR/etc/$PREFIX || logerr "creating config dir"
    logcmd mv $DESTDIR/$PREFIX/config/* $DESTDIR/etc/$PREFIX \
        || logerr "copying config"
}

init
prep_build
save_variable BUILDDIR
clone_go_source mmctl $PROG v$MMCTLVER
restore_variable BUILDDIR
# use clone_github_source instead of clone_go_source
# since mattermost bundles its dependencies
clone_github_source "$PROG-server" "$GITHUB/$PROG/$PROG-server" v$VER
clone_github_source "$PROG-webapp" "$GITHUB/$PROG/$PROG-webapp" v$VER
build mmctl "ADVANCED_VET=FALSE"

if [ $RELVER -lt 151033 ]; then
    export PKG_CONFIG_PATH="$PKG_CONFIG_PATH32"
    export LDFLAGS=" -R$OPREFIX/lib"
else
    export LDFLAGS=" -R$OPREFIX/lib/$ISAPART64"
fi
build $PROG-webapp build
export LDFLAGS=

build $PROG-server build-illumos package
install
install_smf application $PROG.xml
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
