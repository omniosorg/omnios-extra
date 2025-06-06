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

PROG=groovy
VER=4.0.26
PKG=ooce/runtime/groovy-40
SUMMARY="Groovy"
DESC="Java-syntax-compatible object-oriented programming "
DESC+="language for the Java platform."

MAJVER=${VER%.*}
sMAJVER=${MAJVER//./}
set_patchdir patches-$sMAJVER

OPREFIX=$PREFIX
PREFIX+=/$PROG-$MAJVER

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
    -DVERSION=$MAJVER
    -DPKGROOT=$PROG-$MAJVER
    -DMEDIATOR=$PROG -DMEDIATOR_VERSION=$MAJVER
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
