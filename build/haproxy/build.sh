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

PROG=haproxy
VER=3.0.7
PKG=ooce/server/haproxy
SUMMARY="HAProxy - fast and reliable http reverse proxy and load balancer"
DESC="A TCP/HTTP reverse proxy which is particularly suited for high "
DESC+="availability environments."

set_arch 64
test_relver '>=' 151047 && set_clangver

BUILD_DEPENDS_IPS="library/security/openssl library/pcre2"

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DPROG=$PROG
"

pre_configure() {
    typeset arch=$1

    MAKE_ARGS_WS="
        CC=$CC
        DEFINE=\"$CFLAGS ${CFLAGS[$arch]} $CTF_CFLAGS\"
        LDFLAGS=\"$LDFLAGS ${LDFLAGS[$arch]}\"
        TARGET=solaris
        USE_PCRE2=1
        USE_PCRE2_JIT=1
        USE_OPENSSL=1
        USE_ZLIB=1
    "

    MAKE_INSTALL_ARGS_WS="
        PREFIX=$PREFIX
        MANDIR=$PREFIX/share/man
    "

    MAKE_INSTALL_TARGET="install-bin install-man"

    # no configure
    false
}

post_install() {
    logmsg "-- copying sample configs"
    logcmd mkdir -p "$DESTDIR/etc$PREFIX/$PROG" || logerr "mkdir failed"
    logcmd cp $TMPDIR/$BUILDDIR/examples/*.cfg $DESTDIR/etc$PREFIX/$PROG/ \
        || logerr "copying configs failed"

    xform $SRCDIR/files/$PROG-template.xml > $TMPDIR/$PROG.xml
    install_smf ooce $PROG.xml
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
