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

# Copyright 2020 OmniOS Community Edition.  All rights reserved.

. ../../lib/functions.sh

PROG=minio-mc
PKG=ooce/storage/minio-mc
VER=2020-02-20T23-49-54Z
SUMMARY="MinIO client"
DESC="A modern alternative to UNIX commands like ls, cat, cp, mirror, diff, "
DESC+="find etc. It supports filesystems and Amazon S3 compatible cloud "
DESC+="storage service (AWS Signature v2 and v4)"

PROGB=mc
GITHUB=https://github.com/minio

set_arch 64
set_gover 1.13

GOOS=illumos
GOARCH=amd64
MC_RELEASE=RELEASE
export GOOS GOARCH MC_RELEASE

BUILD_DEPENDS_IPS="developer/versioning/git"

# Respect environmental overrides for these to ease development.
: ${MC_SOURCE_REPO:=$GITHUB/$PROGB}
: ${MC_SOURCE_BRANCH:=RELEASE.$VER}

clone_source() {
    clone_github_source $PROGB \
        "$MC_SOURCE_REPO" "$MC_SOURCE_BRANCH"

    BUILDDIR+=/$PROGB
}

get_deps() {
    pushd $TMPDIR/$BUILDDIR > /dev/null

    GOPATH=$TMPDIR/$BUILDDIR/deps
    export GOPATH

    logmsg "getting dependencies (in order to patch them)..."
    logcmd go get -u ./...

    logmsg "fixing permissions on modules (in order to be able to patch them)..."
    logcmd chmod -R u+w $GOPATH

    popd >/dev/null
}

build() {
    pushd $TMPDIR/$BUILDDIR > /dev/null

    logcmd ln -sf stat_openbsd.go pkg/disk/stat_illumos.go \
        || logerr "failed to symlink stat_illumos.go"

    LDFLAGS=" \
    -s -w -X github.com/minio/mc/cmd.Version=$VER \
    -X github.com/minio/mc/cmd.ReleaseTag=RELEASE.$VER \
    "
    logmsg "Building 64-bit"
    logcmd $MAKE LDFLAGS="$LDFLAGS" || logerr "Build failed"

    # $PROG version <ver>
    [ "`./$PROGB --version | awk '{print $3}'`" = "$MC_RELEASE.$VER" ] \
        || logerr "version patch failed."

    popd >/dev/null
}

install() {
    logcmd mkdir -p $DESTDIR/$PREFIX/bin || logerr "mkdir"
    logcmd cp $TMPDIR/$BUILDDIR/mc $DESTDIR/$PREFIX/bin/$PROG \
        || logerr "Cannot install binary"
}

init
clone_source
get_deps
patch_source
prep_build
build
install
VER=${VER%T*}
VER=${VER//-/.} make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
