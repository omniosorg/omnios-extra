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

PROG=unbound
VER=1.23.0
PKG=ooce/network/unbound
SUMMARY="DNS resolver"
DESC="Unbound is a validating, recursive, caching DNS resolver."

OPREFIX=$PREFIX
PREFIX+="/$PROG"

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
"

BUILD_DEPENDS_IPS="ooce/library/libev"

forgo_isaexec

CONFIGURE_OPTS="
    --sysconfdir=/etc$OPREFIX
    --with-run-dir=/var$PREFIX
    --with-libevent=/opt/ooce
    --with-libnghttp2
    --with-pthreads
"

export MAKE

pre_configure() {
    typeset arch=$1

    LDFLAGS[$arch]="-L${SYSROOT[$arch]}$OPREFIX/${LIBDIRS[$arch]}"
    LDFLAGS[$arch]+=" -R$OPREFIX/${LIBDIRS[$arch]}"
}

TESTSUITE_SED="/libtool/d"

post_install() {
    [ $1 = i386 ] && return

    # We do not want to chroot by default as this requires additional setup.
    # Also, people may (should) be running this inside a zone anyway.
    sed -i '
        /chroot:/c\
	chroot: ""
    ' $DESTDIR/etc$PREFIX/unbound.conf

    install_smf network dns-unbound.xml

    manifest_start $TMPDIR/manifest.client
    manifest_add_dir $PREFIX/lib pkgconfig amd64 amd64/pkgconfig
    manifest_add_dir $PREFIX/share/man/man3
    manifest_add_dir $PREFIX/include
    manifest_finalise $TMPDIR/manifest.client $OPREFIX

    manifest_uniq $TMPDIR/manifest.{server,client}
    manifest_finalise $TMPDIR/manifest.server $OPREFIX etc
}

init
download_source $PROG $PROG $VER
prep_build
patch_source
build
run_testsuite
PKG=${PKG/network/library} SUMMARY+=" libraries" \
    make_package -seed $TMPDIR/manifest.client
[ "$FLAVOR" != libsandheaders ] \
    && make_package -seed $TMPDIR/manifest.server server.mog
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
