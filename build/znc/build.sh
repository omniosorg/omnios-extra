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
#
# Copyright 2025 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=znc
VER=1.10.0
VERHUMAN=$VER
PKG=ooce/network/znc
SUMMARY="$PROG - an advanced IRC bouncer"
DESC="An advanced IRC bouncer that is left connected so an IRC client "
DESC+="can disconnect/reconnect without losing the chat session"

OPREFIX=$PREFIX
PREFIX+="/$PROG"

# The icu4c ABI changes frequently. Lock the version
# pulled into each build of znc.
ICUVER=`pkg_ver icu4c`
ICUVER=${ICUVER%%.*}
BUILD_DEPENDS_IPS="=ooce/library/icu4c@$ICUVER"
RUN_DEPENDS_IPS="$BUILD_DEPENDS_IPS"

set_arch 64
set_clangver

XFORM_ARGS="
    -DOPREFIX=${OPREFIX#/}
    -DPREFIX=${PREFIX#/}
    -DPROG=$PROG
    -DPKGROOT=$PROG
"

SKIP_RTIME_CHECK=1
NO_SONAME_EXPECTED=1

CONFIGURE_OPTS="
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_INSTALL_PREFIX=$PREFIX
    -DCMAKE_SKIP_RPATH=ON
    -DWANT_PERL=false
    -DWANT_PYTHON=false
    -DWANT_TCL=false
"
CONFIGURE_OPTS[amd64]="-DCMAKE_INSTALL_LIBDIR=lib"
CONFIGURE_OPTS[aarch64]="-DCMAKE_INSTALL_LIBDIR=lib"
LDFLAGS+=" -lsocket"

pre_build() {
    for f in $SRCDIR/files/*.cpp; do
        bf=`basename $f`
        logmsg "Installing module: $bf"
        logcmd $CP $f $TMPDIR/$EXTRACTED_SRC/modules/ \
            || logerr "failed to install module: $bf"
    done
}

# TODO: if we are going to use clang as a cross-compiler we should
# add support to the framework; this is just a hacky workaround
# to have at least one consumer of clang++ for cross-compiling
pre_configure() {
    typeset arch=$1

    LDFLAGS[$arch]+=" -Wl,-R$OPREFIX/${LIBDIRS[$arch]}"

    ! cross_arch $arch && return

    set_clangver

    PATH=$CROSSTOOLS/$arch/bin:$PATH
    CXX+=" --target=${TRIPLETS[$arch]}"
    LDFLAGS[$arch]+=" -L${SYSROOT[$arch]}$OPREFIX/${LIBDIRS[$arch]}"
}

post_install() {
    install_smf network znc.xml
}

tests() {
    for key in SSL IPv6 Zlib; do
        $EGREP " $key *: yes" $LOGFILE || logerr "$key was not included"
    done
}

init
download_source $PROG $PROG $VER
patch_source
prep_build cmake+ninja
build -noctf    # C++
tests
strip_install
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
