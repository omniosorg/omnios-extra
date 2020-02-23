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

PROG=minio
PKG=ooce/storage/minio
VER=2020-02-20T22-51-23Z
SUMMARY="MinIO server"
DESC="A high Performance Object Storage released under Apache License v2.0. "
DESC+="It is API compatible with Amazon S3 cloud storage service."

GITHUB=https://github.com/$PROG

set_arch 64
set_gover 1.13

OPREFIX=$PREFIX
PREFIX+="/$PROG"

GOOS=illumos
GOARCH=amd64
MINIO_RELEASE=RELEASE
export GOOS GOARCH MINIO_RELEASE

BUILD_DEPENDS_IPS="developer/versioning/git"

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
"

# Respect environmental overrides for these to ease development.
: ${MINIO_SOURCE_REPO:=$GITHUB/$PROG}
: ${MINIO_SOURCE_BRANCH:=RELEASE.$VER}

clone_source() {
    clone_github_source $PROG \
        "$MINIO_SOURCE_REPO" "$MINIO_SOURCE_BRANCH"

    BUILDDIR+=/$PROG
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

    LDFLAGS=" \
    -s -w -X github.com/$PROG/$PROG/cmd.Version=$VER \
    -X github.com/$PROG/$PROG/cmd.ReleaseTag=RELEASE.$VER \
    "
    logmsg "Building 64-bit"
    logcmd $MAKE LDFLAGS="$LDFLAGS" || logerr "Build failed"

    # $PROG version <ver>
    [ "`./$PROG --version | awk '{print $3}'`" = "$MINIO_RELEASE.$VER" ] \
        || logerr "version patch failed."

    popd >/dev/null
}

install() {
    logcmd mkdir -p $DESTDIR/$PREFIX/bin || logerr "mkdir"
    logcmd cp $TMPDIR/$BUILDDIR/$PROG $DESTDIR/$PREFIX/bin/$PROG \
        || logerr "Cannot install binary"
}

init
clone_source
get_deps
patch_source
prep_build
build
install
install_smf application application-$PROG.xml
VER=${VER%T*}
VER=${VER//-/.} make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
