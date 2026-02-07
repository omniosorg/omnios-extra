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

# Copyright 2025 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=navidrome
VER=0.60.0
PKG=ooce/application/navidrome
SUMMARY="$PROG"
DESC="$PROG - an open source web-based music collection server and streamer"

set_arch 64
set_gover
set_nodever 24

RUN_DEPENDS_IPS="
    ooce/multimedia/mediasrv-common
    ooce/multimedia/ffmpeg
"

OPREFIX=$PREFIX
PREFIX+="/$PROG"

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
"

# navidrome requires GNU tools
export PATH="$GNUBIN:$PATH"

build() {
    pushd $TMPDIR/$BUILDDIR > /dev/null

    subsume_arch $BUILDARCH PKG_CONFIG_PATH
    # although it requires pkg-config to make sure the libs/headers are present
    # it does not seem to add the flags where due
    CGO_CPPFLAGS="-I$OPREFIX/include/taglib"
    CGO_LDFLAGS="
        -L$OPREFIX/${LIBDIRS[$BUILDARCH]}
        -Wl,-R$OPREFIX/${LIBDIRS[$BUILDARCH]}
    "
    export CGO_CPPFLAGS CGO_LDFLAGS

    logmsg "Building 64-bit"
    logcmd $MAKE setup || logerr "Setup failed"
    logcmd $MAKE build || logerr "Build failed"

    popd >/dev/null
}

init
clone_go_source $PROG $PROG v$VER
patch_source
prep_build
build
install_go
install_smf ooce $PROG.xml
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
