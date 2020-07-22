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

# Copyright 2020 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/functions.sh

PROG=groovy
VER=3.0.5
PKG=ooce/runtime/groovy-30
SUMMARY="Groovy"
DESC="Java-syntax-compatible object-oriented programming "
DESC+="language for the Java platform."

RUN_DEPENDS_IPS="developer/java/openjdk8"

MAJVER=${VER%.*}
sMAJVER=${MAJVER//./}
PATCHDIR=patches-$sMAJVER

OPREFIX=$PREFIX
PREFIX+=/$PROG-$MAJVER

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
    -DVERSION=$MAJVER
"

copy_package() {
    logcmd mkdir -p $DESTDIR$PREFIX || logerr "mkdir failed"
    logmsg "--- Copying groovy"
    logcmd rsync -a $TMPDIR/$PROG-$VER/ $DESTDIR$PREFIX/ \
        || logerr "rsync groovy"
}

init
download_source $PROG apache-$PROG-binary-$VER
patch_source
prep_build
copy_package
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
