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

PROG=gnutls
VER=3.6.16
PKG=ooce/library/gnutls
SUMMARY="GnuTLS Transport Layer Security Library"
DESC="Secure communications library implementing the SSL, TLS and "
DESC+="DTLS protocols and technologies around them"

# TODO: drop this and the static build of nettle once
# gnutls supports nettle 4.x
NETTLEVER=3.10.2

BUILD_DEPENDS_IPS="ooce/library/nettle"

forgo_isaexec

SKIP_RTIME_CHECK=1
TESTSUITE_FILTER='^[A-Z#][A-Z ]'

CONFIGURE_OPTS="
    --disable-static
    --disable-doc
    --enable-manpages
    --disable-openssl-compatibility
    --disable-guile
    --disable-valgrind-tests
    --without-idn
    --without-p11-kit
    --without-tpm
    --enable-local-libopts
    --with-default-trust-store-file=/etc/ssl/cacert.pem
    --with-unbound-root-key-file=/var$PREFIX/unbound/root.key
"

init
prep_build autoconf -autoreconf

#########################################################################
# Download and build nettle for headers/linking
# the lecacy libraries are still shipped with the nettle package

save_buildenv

CONFIGURE_OPTS="--disable-static"
CONFIGURE_OPTS[aarch64]+=" HOST_CC=/opt/gcc-$DEFAULT_GCC_VER/bin/gcc"
CPPFLAGS="-I/usr/include/gmp"

build_dependency nettle nettle-$NETTLEVER \
    nettle nettle $NETTLEVER

restore_buildenv

#########################################################################

pre_configure() {
    typeset arch=$1

    # TODO: can be dropped once gnutls supports nettle 4.x
    CPPFLAGS+=" -I$DEPROOT$PREFIX/include"
    LDFLAGS[$arch]+=" -L$DEPROOT$PREFIX/${LIBDIRS[$arch]}"

    # just using '--sysroot' does not work for cross-builds.
    CPPFLAGS+=" -I${SYSROOT[$arch]}/usr/include/gmp"
    CPPFLAGS+=" -I${SYSROOT[$arch]}$PREFIX/include"
    CPPFLAGS+=" -I${SYSROOT[$arch]}$PREFIX/unbound/include"
    CFLAGS[aarch64]+=" -mtls-dialect=trad"
    LDFLAGS[$arch]+=" -L${SYSROOT[$arch]}$PREFIX/${LIBDIRS[$arch]}"
    LDFLAGS[$arch]+=" -L${SYSROOT[$arch]}$PREFIX/unbound/${LIBDIRS[$arch]}"
    LDFLAGS[$arch]+=" -R$PREFIX/${LIBDIRS[$arch]}"
    LDFLAGS[$arch]+=" -R$PREFIX/unbound/${LIBDIRS[$arch]}"
}

export MAKE

note -n "-- Building $PROG"

download_source $PROG $PROG $VER
patch_source
build
run_testsuite check
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
