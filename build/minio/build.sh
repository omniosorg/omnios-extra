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

# Copyright 2024 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=minio
PKG=ooce/storage/minio
VER=2024-12-13T22-19-12Z
SUMMARY="MinIO server"
DESC="A high Performance Object Storage. "
DESC+="It is API compatible with Amazon S3 cloud storage service."

set_arch 64
set_gover

OPREFIX=$PREFIX
PREFIX+="/$PROG"

MINIO_RELEASE=RELEASE
VERS="`echo $VER | $PERL -pe 's/(T\d\d)-(\d\d)-(\d\dZ)$/\1:\2:\3/'`"
export MINIO_RELEASE VERS

BUILD_DEPENDS_IPS="developer/versioning/git"

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
"

build() {
    pushd $TMPDIR/$BUILDDIR > /dev/null

    logmsg "Building 64-bit"
    logcmd $MAKE || logerr "Build failed"

    # $PROG version <ver>
    [ "`./$PROG --version | awk 'NR==1 {print $3}'`" = "$MINIO_RELEASE.$VER" ] \
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
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
