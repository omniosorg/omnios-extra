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

PROG=zadm
VER=github-latest
PKG=ooce/util/zadm
SUMMARY="zone admin tool"
DESC="$PROG - $SUMMARY"

NOVNCVER=1.2.0

if [ $RELVER -lt 151034 ]; then
    logmsg "--- $PKG is not built for r$RELVER"
    exit 0
fi

_MIRROR=$MIRROR
set_mirror "$OOCEGITHUB/$PROG/releases/download"

RUN_DEPENDS_IPS="network/socat"

OPREFIX=$PREFIX
PREFIX+="/$PROG"

set_arch 64

SKIP_LICENCES=MPLv2

# the Zstd module contains BMI instructions even when built on an older CPU
BMI_EXPECTED=1

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
    -DPKGROOT=$PROG
    -DNOVNCVER=$NOVNCVER
"

CONFIGURE_OPTS_64="
    --prefix=$PREFIX
    --sysconfdir=/etc$PREFIX
    --localstatedir=/var$PREFIX
"

bundle_novnc() {
    note -n "Bundling noVNC"

    set_mirror $_MIRROR
    save_variable EXTRACTED_SRC
    set_builddir noVNC-$NOVNCVER

    download_source novnc v$NOVNCVER
    logcmd mkdir -p $DESTDIR$PREFIX/novnc || logerr "mkdir novnc failed"

    pushd $TMPDIR/$BUILDDIR >/dev/null
    logcmd rsync -a vnc.html app core vendor $DESTDIR$PREFIX/novnc/ \
        || logerr "rsync failed"
    popd >/dev/null

    restore_variable EXTRACTED_SRC
}

init
download_source "v$VER" $PROG $VER
patch_source
prep_build
build
bundle_novnc
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
