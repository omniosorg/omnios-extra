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

# Copyright 2019 OmniOS Community Edition (OmniOSce) Association.
#
. ../../lib/functions.sh

PROG=go
PKG=ooce/developer/go-111
VER=1.11.5
VERHUMAN=$VER
SUMMARY="The Go Programming Language"
DESC="An open source programming language that makes it easy to build simple, "
DESC+="reliable, and efficient software."

BUILDDIR=$PROG

set_arch 64

MAJVER=${VER%.*}
sMAJVER=${MAJVER//./}
PATCHDIR=patches-$sMAJVER

OPREFIX=$PREFIX
PREFIX+=/$PROG-$MAJVER

export GOROOT_FINAL=$PREFIX
export GOROOT_BOOTSTRAP="$OPREFIX/$PROG-1.10"
export GOPATH="$DESTDIR$PREFIX"

BUILD_DEPENDS_IPS=ooce/developer/go-110

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
    -DVERSION=$MAJVER
    -DsVERSION=$sMAJVER
"

make_clean() {
    pushd $TMPDIR/$BUILDDIR/src >/dev/null
    logcmd ./clean.bash
    popd >/dev/null
}

configure64() {
    logcmd mkdir -p $DESTDIR/$OPREFIX \
        || logerr "--- failed to create Go install directory."
}

make_prog64() {
    pushd $TMPDIR/$BUILDDIR/src >/dev/null
    logmsg "--- make"
    logcmd ./make.bash || logerr "--- make failed"
    popd >/dev/null
}

make_install64() {
    logmsg "--- make install"
    logcmd mv $TMPDIR/$BUILDDIR $DESTDIR$GOROOT_FINAL \
        || logerr "--- make install failed"
}

init
download_source $PROG "$PROG$VER.src"
patch_source
prep_build
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
