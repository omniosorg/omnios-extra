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

PROG=victorialogs
VER=1.50.0
PKG=ooce/database/victorialogs
SUMMARY="VictoriaLogs"
DESC="A high-performance, lightweight, zero-config, schema-free database for logs."

DATA=var/${PREFIX#/}/$PROG

set_arch 64
set_gover

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DPROG=$PROG
    -DUSER=$PROG
    -DGROUP=$PROG
    -DDATA=$DATA
    -DVERSION=$VER
    -DVL=victoria-logs
"

build() {
    pushd $TMPDIR/$BUILDDIR > /dev/null

    logmsg "Building $PROG"
    export CGO_ENABLED=0
    export GOOS=illumos

    logcmd $MAKE \
        || logerr "Unable to build victoria-logs"

    logcmd $MAKE vlutils-pure \
        || logerr "Unable to build vlutils-pure"

    popd >/dev/null
}

# make it so
init
clone_go_source VictoriaLogs VictoriaMetrics v$VER
prep_build
build
install_go bin/victoria-logs victoria-logs
install_go bin/vlogscli-pure vlogscli
xform files/$PROG-template.xml > $TMPDIR/$PROG.xml
install_smf application $PROG.xml
xform files/victoria-logs-profile-template.xml \
    > $TMPDIR/victoria-logs-profile.xml
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
