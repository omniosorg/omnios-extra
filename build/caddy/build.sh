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

# Copyright 2024 Guo-Rong Koh

. ../../lib/build.sh

PROG=caddy
VER=2.11.1
PKG=ooce/server/caddy
SUMMARY="Caddy web server"
DESC="Fast and extensible multi-platform HTTP/1-2-3 web server with automatic \
HTTPS"

CONFIG=etc/${PREFIX#/}/$PROG
DATA=var/${PREFIX#/}/$PROG

RUN_DEPENDS_IPS="ooce/server/webservd-common"

set_arch amd64
set_gover

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DPROG=$PROG
    -DVERSION=$VER
    -DUSER=webservd -DGROUP=webservd
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

    logcmd go build -o caddy cmd/caddy/main.go || logerr "Unable to build $PROG"

    popd >/dev/null
}

# create package functions
init
clone_go_source $PROG caddyserver v$VER
patch_source
prep_build
build
install_go $PROG
xform files/$PROG-template.xml > $TMPDIR/$PROG.xml
install_smf network $PROG.xml
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
