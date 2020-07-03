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
VER=2020-06-26T19-56-55Z
SUMMARY="MinIO client"
DESC="A modern alternative to UNIX commands like ls, cat, cp, mirror, diff, "
DESC+="find etc. It supports filesystems and Amazon S3 compatible cloud "
DESC+="storage service (AWS Signature v2 and v4)"

set_arch 64
set_gover 1.13

GOOS=illumos
GOARCH=amd64
MC_RELEASE=RELEASE
export GOOS GOARCH MC_RELEASE

build() {
    pushd $TMPDIR/$BUILDDIR > /dev/null

    LDFLAGS=" \
    -s -w -X github.com/minio/mc/cmd.Version=$VER \
    -X github.com/minio/mc/cmd.ReleaseTag=RELEASE.$VER \
    "
    logmsg "Building 64-bit"
    logcmd $MAKE LDFLAGS="$LDFLAGS" || logerr "Build failed"

    # $PROG version <ver>
    [ "`./mc --version | awk '{print $3}'`" = "$MC_RELEASE.$VER" ] \
        || logerr "version patch failed."

    popd >/dev/null
}

init
clone_go_source mc minio "RELEASE.$VER"
patch_source
prep_build
build
install_go mc
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
