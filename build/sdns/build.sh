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

PROG=sdns
VER=1.3.6
PKG=ooce/network/sdns
SUMMARY="sdns"
DESC="Simple DNS Server"

set_arch 64
set_gover 1.22

# No configure
configure_amd64() { :; }

CONFIG=etc/${PREFIX#/}/$PROG
DATA=var/${PREFIX#/}/$PROG

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DPROG=$PROG
    -DVERSION=$VER
    -DUSER=sdns -DGROUP=sdns
    -DCONFIG=$CONFIG
    -DDATA=$DATA
    -DXDG_CONFIG=${CONFIG%/$PROG}
    -DXDG_DATA=${DATA%/$PROG}
"

build() {
    pushd $TMPDIR/$BUILDDIR > /dev/null

    logmsg "Building $PROG"
    export CGO_ENABLED=0
    export GOOS=illumos

    logcmd go build || logerr "Unable to build $PROG"

    popd >/dev/null
}

init
clone_go_source $PROG semihalev v$VER
patch_source
print_config
prep_build
build
install_go $PROG
xform files/$PROG-template.xml > $TMPDIR/$PROG.xml
install_smf network $PROG.xml
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
