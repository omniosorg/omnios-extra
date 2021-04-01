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

# Copyright 2021 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/functions.sh

PROG=gnutls
VER=3.7.1
VER_MAJ=3.7
PKG=ooce/security/gnutls
SUMMARY="gnutls"
DESC="GnuTLS is a portable ANSI C based library which implements the TLS 1.0 and SSL"
DESC+="3.0 protocols. The library does not include any patented algorithms and is"
DESC+="available under the GNU Lesser GPL license."

OPREFIX=$PREFIX
PREFIX+="/$PROG"
CFLAGS+=" -I/usr/include/gmp"

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
    -DPKGROOT=$PROG
"

export MAKE
CONFIGURE_OPTS="
	--disable-openssl-compatibility
	--without-idn
	--without-tpm
	--disable-valgrind-tests
	--enable-local-libopts
	--with-included-libtasn1
	--with-included-unistring
	--without-p11-kit
	--disable-hardware-acceleration
"

init
set_mirror "https://gnupg.org/ftp/gcrypt"
set_checksum sha256 "3777d7963eca5e06eb315686163b7b3f5045e2baac5e54e038ace9835e5cac6f"
download_source $PROG/v$VER_MAJ $PROG $VER
patch_source
prep_build
build
strip_install
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
