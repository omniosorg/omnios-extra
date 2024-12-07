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

# Copyright 2023 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=gnutls
VER=3.6.16
PKG=ooce/library/gnutls
SUMMARY="GnuTLS Transport Layer Security Library"
DESC="Secure communications library implementing the SSL, TLS and "
DESC+="DTLS protocols and technologies around them"

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

export MAKE

pre_configure() {
    typeset arch=$1

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

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
run_testsuite check
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
