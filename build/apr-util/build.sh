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

# Copyright 2024 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=apr-util
VER=1.6.3
PKG=ooce/library/apr-util
SUMMARY="Utilities for the Apache Portable Runtime library"
DESC="The Apache Portable Runtime is a library \
of C data structures and routines, forming a system portability \
layer that covers as many operating systems as possible, including \
Unices, Win32, BeOS, OS/2."

# does not yet build with gcc 14
((GCCVER > 13)) && set_gccver 13

BUILD_DEPENDS_IPS+="
    ooce/library/apr
"

CONFIGURE_OPTS="
    --with-openssl
    --with-crypto
    --without-pgsql
    --with-gdbm
    --with-ldap=ldap
    --with-lber=lber
    --with-ldap-include=$PREFIX/include
"

CONFIGURE_OPTS[i386]+="
    --with-apr=$PREFIX/bin/i386/apr-1-config
    --with-berkeley-db=$PREFIX/include:$PREFIX/lib
"

CONFIGURE_OPTS[amd64]+="
    --with-apr=$PREFIX/bin/amd64/apr-1-config
    --with-berkeley-db=$PREFIX/include:$PREFIX/lib/amd64
"

LDFLAGS[i386]+=" -L$PREFIX/lib -R$PREFIX/lib"
LDFLAGS[amd64]+=" -L$PREFIX/lib/amd64 -R$PREFIX/lib/amd64"

post_install() {
    typeset arch=$1

    pushd $DESTDIR/$PREFIX >/dev/null

    # Unfortunately, libtool messes up the runtime library path
    # in each apr-util-1 library. Fixing this up post-install
    # for now, there may be a better way to do it.
    typeset rpath="$PREFIX/${LIBDIRS[$arch]}/apr-util-1"
    rpath+=":$PREFIX/${LIBDIRS[$arch]}"
    rpath+=":/usr/gcc/$GCCVER/${LIBDIRS[$arch]}"

    for f in ${LIBDIRS[$arch]}/apr-util-1/*.so; do
        [ -f $f -a ! -h $f ] || continue
        logmsg "--- fixing runpath in $f"
        logcmd $ELFEDIT -e "dyn:value -s RUNPATH $rpath" $f
        logcmd $ELFEDIT -e "dyn:value -s RPATH $rpath" $f
    done

    popd >/dev/null
}

init
download_source apr $PROG $VER
patch_source
prep_build
build
run_testsuite
strip_install
make_isa_stub
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
