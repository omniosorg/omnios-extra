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

# Copyright 2023 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=mattermost
VER=7.5.2
MMCTLVER=7.5.0
PKG=ooce/application/mattermost
SUMMARY="$PROG"
DESC="All your team communication in one place, "
DESC+="instantly searchable and accessible anywhere."

set_arch 64
set_gover
set_nodever

BUILD_DEPENDS_IPS+="
    ooce/library/libpng
"

OPREFIX=$PREFIX
PREFIX+="/$PROG"

export BUILD_NUMBER=$VER
export PATH="$GNUBIN:$PATH"
subsume_arch $BUILDARCH PKG_CONFIG_PATH

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
"

# Unfortunately, the mattermost webapp has a number of dependencies which are
# specified with ssh:// URLs for accessing github. npm is unable to retrieve
# these unless the build user has an SSH key for accessing github, and that key
# cannot be protected with a passphrase.
# To work around this, we create a git config file that does URL rewrites to
# translate these back to https://github.com/ and a small git stub to force use
# of that config file since 'npm' strips the environment before invoking git.
gitenv() {
    GITCONFIG=$TMPDIR/gitconfig
    : > $GITCONFIG
    logcmd $GIT config -f $GITCONFIG url."github.com/".insteadOf git@github.com/
    logcmd $GIT config -f $GITCONFIG url."https://".insteadOf ssh://

    GITBIN=$TMPDIR/gitbin
    logcmd $RM -rf $GITBIN
    logcmd $MKDIR $GITBIN || logerr "Cannot create $GITBIN"
    $CAT << EOM > $GITBIN/git
#!/bin/sh
GIT_CONFIG_GLOBAL=$GITCONFIG /usr/bin/git "\$@"
EOM
    logcmd $CHMOD +x $GITBIN/git

    PATH="$GITBIN:$PATH"
}

download_source() {
    gitenv
    save_variables BUILDDIR EXTRACTED_SRC

    clone_go_source mmctl $PROG v$MMCTLVER
    restore_variables BUILDDIR EXTRACTED_SRC

    GOPATH=$TMPDIR/$BUILDDIR/$PROG-server/_deps
    clone_go_source "$PROG-server" $PROG v$VER
    restore_variables BUILDDIR EXTRACTED_SRC

    clone_github_source -dependency "$PROG-webapp" \
        "$GITHUB/$PROG/$PROG-webapp" v$VER
    restore_variables BUILDDIR EXTRACTED_SRC

    ((EXTRACT_MODE)) && exit
}

build_component() {
    prog="$1"; shift

    note -n "Building $prog"

    EXTRACTED_SRC+=/$prog patch_source patches-$prog

    export GOPATH=$TMPDIR/$BUILDDIR/$prog/_deps

    pushd $TMPDIR/$BUILDDIR/$prog > /dev/null
    logcmd $MAKE "$@" || logerr "Build failed"
    popd >/dev/null

    logmsg "Fixing permissions on $prog dependencies"
    logcmd $CHMOD -R u+w $GOPATH
}

build_mmctl() {
    build_component mmctl "ADVANCED_VET=FALSE"
}

build_webapp() {
    save_variable LDFLAGS
    LDFLAGS+=" -R$OPREFIX/lib/amd64"
    subsume_arch $BUILDARCH LDFLAGS
    build_component $PROG-webapp build
    restore_variable LDFLAGS
}

build_server() {
    build_component $PROG-server build-illumos package-illumos
}

build() {
    for component in mmctl webapp server; do
        [ -n "$FLAVOR" -a "$FLAVOR" != $component ] && continue
        build_$component
    done
}

install() {
    logcmd $MKDIR -p $DESTDIR/$OPREFIX || logerr "mkdir"

    logcmd $RSYNC -a $TMPDIR/$BUILDDIR/$PROG-server/dist/$PROG \
        $DESTDIR/$OPREFIX/ || logerr "copying dist"

    logcmd $CP $TMPDIR/$BUILDDIR/mmctl/mmctl $DESTDIR/$PREFIX/bin \
        || logerr "copying mmctl"

    logmsg "Creating config path"
    logcmd $MKDIR -p $DESTDIR/etc/$PREFIX || logerr "creating config dir"
    logcmd $MV $DESTDIR/$PREFIX/config/* $DESTDIR/etc/$PREFIX \
        || logerr "copying config"
}

init
prep_build
download_source
build
install
install_smf application $PROG.xml
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
