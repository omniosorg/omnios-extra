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

PROG=soju
VER=0.10.1
PKG=ooce/network/soju
SUMMARY="A user-friendly IRC bouncer"
DESC="soju is a user-friendly IRC bouncer. soju connects to upstream "
DESC+="IRC servers on behalf of the user to provide extra functionality."
REPO="https://codeberg.org/emersion/"

OPREFIX=$PREFIX
PREFIX+=/$PROG

set_arch 64
set_gover

BASEDIR=$PREFIX
EXECFILE=$PREFIX/bin/$PROG

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DBASEDIR=${BASEDIR#/}
    -DEXECFILE=$EXECFILE
    -DUSER=$PROG
    -DGROUP=$PROG
    -DPROG=$PROG
    -DPKGROOT=$PROG
"
#export SCDOC=$USRBIN/true

pre_configure() {
    # No configure
    false
}

pre_build() {
    typeset arch=$1
    export SCDOC=$USRBIN/true
}

pre_install() {
    install_go $PROG
    install_go ${PROG}db ${PROG}db
    install_go ${PROG}ctl ${PROG}ctl
    
    typeset arch=$1

    _destdir=$DESTDIR
    cross_arch $arch && _destdir+=.$arch

    xform $SRCDIR/files/$PROG.xml > $TMPDIR/$PROG.xml
    DESTDIR=$_destdir install_smf ooce $PROG.xml
    false
}

init
clone_github_source $PROG "$REPO/$PROG" v$VER
append_builddir $PROG
patch_source
prep_build
build -noctf
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
