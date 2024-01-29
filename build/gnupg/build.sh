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
# Copyright 2024 OmniOS Community Edition (OmniOSce) Association.
#
. ../../lib/build.sh

PROG=gnupg
VER=2.4.4
PKG=ooce/security/gnupg
SUMMARY="$PROG - GNU Privacy Guard"
DESC="A complete and free implementation of the OpenPGP standard"

# we don't track the versions in doc/packages.md
# check for updates when gnupg is updated
LIBGPGERRORVER=1.47
LIBGCRYPTVER=1.10.3
LIBKSBAVER=1.6.5
LIBASSUANVER=2.5.6
NPTHVER=1.6
PINENTRYVER=1.2.1

OPREFIX=$PREFIX
PREFIX+="/$PROG"

set_arch 64

SKIP_RTIME_CHECK=1
TESTSUITE_FILTER='^[A-Z0-9][A-Z0-9 ]'

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
    -DPKGROOT=$PROG
    -DGPGERROR=$LIBGPGERRORVER
    -DGCRYPT=$LIBGCRYPTVER
    -DKSBA=$LIBKSBAVER
    -DASSUAN=$LIBASSUANVER
    -DNPTH=$NPTHVER
    -DPINENTRY=$PINENTRYVER
"

export CC_FOR_BUILD=/opt/gcc-$DEFAULT_GCC_VER/bin/gcc

init
prep_build

#########################################################################
# Download and build static versions of dependencies

save_buildenv

CONFIGURE_OPTS=" --disable-shared --enable-static"

save_variable CONFIGURE_OPTS
CONFIGURE_OPTS+=" --enable-install-gpg-error-config"
build_dependency libgpg-error libgpg-error-$LIBGPGERRORVER \
    $PROG/libgpg-error libgpg-error $LIBGPGERRORVER
restore_variable CONFIGURE_OPTS

CPPFLAGS+=" -I$DEPROOT$PREFIX/include"
LDFLAGS[amd64]+=" -L$DEPROOT$PREFIX/lib/amd64"
LDFLAGS[aarch64]+=" -L$DEPROOT$PREFIX/lib"
CONFIGURE_OPTS+=" --with-libgpg-error-prefix=$DEPROOT$PREFIX"

build_dependency libgcrypt libgcrypt-$LIBGCRYPTVER \
    $PROG/libgcrypt libgcrypt $LIBGCRYPTVER

build_dependency libksba libksba-$LIBKSBAVER \
    $PROG/libksba libksba $LIBKSBAVER

build_dependency libassuan libassuan-$LIBASSUANVER \
    $PROG/libassuan libassuan $LIBASSUANVER

build_dependency npth npth-$NPTHVER \
    $PROG/npth npth $NPTHVER

save_variable DEPROOT

CONFIGURE_OPTS+=" --with-libassuan-prefix=$DEPROOT$PREFIX"

pre_configure() {
    typeset arch=$1

    CPPFLAGS+=" -I${SYSROOT[$arch]}/usr/include/ncurses"
}

build_dependency -ctf -merge pinentry pinentry-$PINENTRYVER \
    $PROG/pinentry pinentry $PINENTRYVER

restore_variable DEPROOT
restore_buildenv

#########################################################################

# libdns does currently not work reliably on OmniOS; disable it
CONFIGURE_OPTS[WS]="
    --disable-static
    --disable-libdns
    --sysconfdir=/etc$OPREFIX
    --with-libgpg-error-prefix=$DEPROOT$PREFIX
    --with-libgcrypt-prefix=$DEPROOT$PREFIX
    --with-libassuan-prefix=$DEPROOT$PREFIX
    --with-libksba-prefix=$DEPROOT$PREFIX
    KSBA_CONFIG=$DEPROOT$PREFIX/bin/ksba-config
    --with-npth-prefix=$DEPROOT$PREFIX
    --with-pinentry-pgm=$PREFIX/bin/pinentry
    LDAPLIBS=\"-lldap_r -llber\"
"

pre_configure() {
    typeset arch=$1

    CPPFLAGS+=" -I$DEPROOT$PREFIX/include -I$OPREFIX/include"
    LDFLAGS[$arch]+=" -L$DEPROOT$PREFIX/${LIBDIRS[$arch]}"
    LDFLAGS[$arch]+=" -L${SYSROOT[$arch]}$OPREFIX/${LIBDIRS[$arch]}"
    LDFLAGS[$arch]+=" -R$OPREFIX/${LIBDIRS[$arch]}"
}

PATH+=":$DEPROOT$PREFIX/bin"

download_source $PROG $PROG $VER
patch_source
build
install_execattr
run_testsuite check
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
