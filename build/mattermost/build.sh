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

# Copyright 2026 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=mattermost
VER=11.7.10
# check for the current morph version/commit hash and create a patched branch in
# https://github.com/omniosorg/morph; then point to that branch
MORPHBRANCH=il_1.1.0
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

# The webapp build optimises images using 'sharp', for which no illumos
# binaries exist. Ask npm to install its WebAssembly build instead, which is
# only selected when the target CPU is 'wasm32'. No other optional,
# platform-specific package matches illumos so nothing else is affected.
export npm_config_cpu=wasm32

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

    clone_github_source -dependency $PROG $GITHUB/$PROG/$PROG v$VER

    export GOPATH=$TMPDIR/$BUILDDIR/$PROG/server/_deps

    pushd $TMPDIR/$BUILDDIR/$PROG/server >/dev/null
    logmsg "Replacing morph"
    logcmd go mod edit -replace \
        github.com/mattermost/morph=github.com/omniosorg/morph@$MORPHBRANCH \
        || logerr "Failed to replace morph"

    # external_imports.go is guarded by '//go:build enterprise' and references
    # the private github.com/mattermost/enterprise repository. We never build
    # with that tag, but 'go get ./...' walks every build configuration and
    # would attempt to fetch those modules. Move the file aside; this matches
    # what Mattermost's own Makefile does for 'modules-tidy' etc.
    logmsg "Stashing enterprise external_imports.go"
    logcmd $MV enterprise/external_imports.go{,.orig} \
        || logerr "Failed to move external_imports.go aside"

    logmsg "Getting go dependencies"
    logcmd go get -d ./... || logerr "failed to get dependencies"

    logmsg "Fixing permissions on dependencies"
    logcmd $CHMOD -R u+w $GOPATH

    set_builddir $BUILDDIR/$PROG

    patch_source

    ((EXTRACT_MODE)) && exit

    popd >/dev/null
}

build() {
    note -n "Building $PROG"

    pushd $TMPDIR/$BUILDDIR/server >/dev/null
    logcmd $MAKE build-client build-illumos package-prep \
        || logerr "Build failed"
    popd >/dev/null

    logmsg "Fixing permissions on $PROG dependencies"
    logcmd $CHMOD -R u+w $GOPATH
}

install() {
    logcmd $MKDIR -p $DESTDIR/$PREFIX/bin || logerr "mkdir"

    logcmd $RSYNC -a $TMPDIR/$BUILDDIR/server/dist/$PROG \
        $DESTDIR/$OPREFIX/ || logerr "copying dist"

    logcmd $CP $TMPDIR/$BUILDDIR/server/bin/$PROG \
        $DESTDIR/$PREFIX/bin/ || logerr "copying $PROG"
    logcmd $CP $TMPDIR/$BUILDDIR/server/bin/mmctl \
        $DESTDIR/$PREFIX/bin/ || logerr "copying mmctl"

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
