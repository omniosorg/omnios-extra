#!/usr/bin/bash
#
# {{{ CDDL HEADER START
#
# The contents of this file are subject to the terms of the
# Common Development and Distribution License, Version 1.0 only
# (the "License").  You may not use this file except in compliance
# with the License.
#
# You can obtain a copy of the license at usr/src/OPENSOLARIS.LICENSE
# or http://www.opensolaris.org/os/licensing.
# See the License for the specific language governing permissions
# and limitations under the License.
#
# When distributing Covered Code, include this CDDL HEADER in each
# file and include the License file at usr/src/OPENSOLARIS.LICENSE.
# If applicable, add the following below this CDDL HEADER, with the
# fields enclosed by brackets "[]" replaced with your own identifying
# information: Portions Copyright [yyyy] [name of copyright owner]
#
# CDDL HEADER END }}}
#
# Copyright 2011-2013 OmniTI Computer Consulting, Inc.  All rights reserved.
# Copyright 2018 OmniOS Community Edition (OmniOSce) Association.

# Use is subject to license terms.

. ../../lib/functions.sh

PROG=apache-ant
VER=1.9.10 # stay on 1.9.x, 1.10.x requires Java8
VERHUMAN=$VER
JUNITVER=4.12
PKG=ooce/developer/build/ant
SUMMARY="Apache Ant is a Java library and command-line tool that help building software."
DESC="$SUMMARY"
PREFIX=$PREFIX/$PROG

BUILD_DEPENDS_IPS="developer/java/jdk"
RUN_DEPENDS_IPS="runtime/java runtime/perl runtime/python-27"

BUILDARCH=32
JAVA_HOME="/usr/jdk"
export JAVA_HOME

fetch_junit() {
    pushd $TMPDIR/$BUILDDIR/lib/optional > /dev/null
    logmsg "Fetching JUnit for build"
    logcmd $WGET $MIRROR/junit/junit-${JUNITVER}.jar || \
        logerr "-- Failed to download junit-${JUNITVER} jar file."
    popd > /dev/null
}

build_ant() {
    pushd $TMPDIR/$BUILDDIR > /dev/null
    logmsg "Building Ant"
    logcmd /bin/sh ./build.sh -Ddist.dir=${DESTDIR}${PREFIX} || \
        logerr "-- Build failed"
    popd > /dev/null
}

init
download_source  $PROG $PROG ${VER}-src
patch_source
prep_build
fetch_junit
build_ant
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
