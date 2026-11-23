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

PROG=gitea-runner
VER=6.0.1
PKG=ooce/application/gitea-runner
SUMMARY="Gitea Actions runner"
DESC="Runner for Gitea Actions; on illumos it runs workflow jobs directly "
DESC+="on the host"

OPREFIX=$PREFIX
PREFIX+=/$PROG

# the archive from gitea.com unpacks to the repository name
set_builddir runner

set_arch 64
set_gover 1.27

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
    -DUSER=$PROG
    -DGROUP=$PROG
    -DVERSION=$VER
"

# the runner executes git to fetch actions, and so do most host-mode jobs
RUN_DEPENDS_IPS=developer/versioning/git

# build with the go version from set_gover, not a toolchain downloaded for go.mod
export GOTOOLCHAIN=local

build() {
    pushd $TMPDIR/$BUILDDIR > /dev/null

    logmsg "Building $PROG"
    export GOPATH=$TMPDIR/$BUILDDIR/_deps
    # as for the upstream release binaries
    export CGO_ENABLED=0

    # there is no git repository to derive the version from
    logcmd $MAKE build RELASE_VERSION=$VER || logerr "Build failed"

    logmsg "Fixing permissions on dependencies"
    logcmd $CHMOD -R u+w $GOPATH

    # gitea-runner version v<ver>
    [ "`./$PROG --version | awk '{print $NF}'`" = "v$VER" ] \
        || logerr "version check failed."

    popd >/dev/null
}

install() {
    install_go

    logcmd $MKDIR -p $DESTDIR/etc/$PREFIX || logerr "mkdir etc"
    $DESTDIR/$PREFIX/bin/$PROG config generate \
        > $DESTDIR/etc/$PREFIX/config.yaml \
        || logerr "Cannot generate the default configuration"
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
install
xform files/$PROG-template.xml > $TMPDIR/$PROG.xml
install_smf ooce $PROG.xml
add_notes README.install
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
