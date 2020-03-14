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
VER=2020-03-14T02-21-58Z
SUMMARY="MinIO server"
DESC="A high Performance Object Storage released under Apache License v2.0. "
DESC+="It is API compatible with Amazon S3 cloud storage service."

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

init
clone_go_source $PROG $PROG "RELEASE.$VER"
patch_source
prep_build
build
install_go
install_smf application application-$PROG.xml
VER=${VER%T*}
VER=${VER//-/.} make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
