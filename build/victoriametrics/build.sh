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

PROG=victoriametrics
VER=1.102.8
PKG=ooce/database/victoriametrics
SUMMARY="VictoriaMetrics"
DESC="Fast, cost-effective monitoring solution and time series database."

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
    -DVM=victoria-metrics
    -DVMAGENT=vmagent
"

build() {
    pushd $TMPDIR/$BUILDDIR > /dev/null

    logmsg "Building $PROG"
    export CGO_ENABLED=0
    export GOOS=illumos

    logcmd $MAKE victoria-metrics-pure \
        || logerr "Unable to build victoria-metrics-pure"
    logcmd $MAKE vmutils-pure \
        || logerr "Unable to build vmutils-pure"

    popd >/dev/null
}

# make it so
init
clone_go_source VictoriaMetrics VictoriaMetrics v$VER
prep_build
build
install_go bin/victoria-metrics-pure victoria-metrics
install_go bin/vmagent-pure vmagent
install_go bin/vmbackup-pure vmbackup
install_go bin/vmctl-pure vmctl
install_go bin/vmrestore-pure vmrestore
xform files/$PROG-template.xml > $TMPDIR/$PROG.xml
install_smf application $PROG.xml
xform files/victoria-metrics-profile-template.xml \
    > $TMPDIR/victoria-metrics-profile.xml
add_notes README.install
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
