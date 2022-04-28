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
# Copyright 2022 OmniOS Community Edition (OmniOSce) Association.
#
. ../../lib/build.sh

PROG=gnupg
VER=2.3.6
PKG=ooce/security/gnupg
SUMMARY="$PROG - GNU Privacy Guard"
DESC="A complete and free implementation of the OpenPGP standard"

# we don't track the versions in doc/packages.md
# check for updates when gnupg is updated
LIBGPGERRORVER=1.45
LIBGCRYPTVER=1.10.1
LIBKSBAVER=1.6.0
LIBASSUANVER=2.5.5
NPTHVER=1.6
PINENTRYVER=1.2.0

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

init
prep_build

#########################################################################
# Download and build static versions of dependencies

save_buildenv

CONFIGURE_OPTS=" --disable-shared --enable-static"

build_dependency libgpg-error libgpg-error-$LIBGPGERRORVER \
    $PROG/libgpg-error libgpg-error $LIBGPGERRORVER

CPPFLAGS+=" -I$DEPROOT$PREFIX/include"
LDFLAGS64+=" -L$DEPROOT$PREFIX/lib/$ISAPART64"
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
build_dependency -ctf -merge pinentry pinentry-$PINENTRYVER \
    $PROG/pinentry pinentry $PINENTRYVER

restore_variable DEPROOT
restore_buildenv

#########################################################################

# libdns does currently not work reliably on OmniOS; disable it
CONFIGURE_OPTS_WS="
    --disable-static
    --disable-libdns
    --sysconfdir=/etc$OPREFIX
    --with-libgpg-error-prefix=$DEPROOT$PREFIX
    --with-libgcrypt-prefix=$DEPROOT$PREFIX
    --with-libassuan-prefix=$DEPROOT$PREFIX
    --with-libksba-prefix=$DEPROOT$PREFIX
    --with-npth-prefix=$DEPROOT$PREFIX
    --with-pinentry-pgm=$PREFIX/bin/pinentry
    LDAPLIBS=\"-lldap_r -llber\"
"
CPPFLAGS+=" -I$DEPROOT$PREFIX/include -I$OPREFIX/include"
LDFLAGS64+=" -L$DEPROOT$PREFIX/lib/$ISAPART64"
LDFLAGS64+=" -L$OPREFIX/lib/$ISAPART64 -R$OPREFIX/lib/$ISAPART64"
PATH+=":$DEPROOT$PREFIX/bin"

download_source $PROG $PROG $VER
patch_source
build -ctf
install_execattr
run_testsuite check
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
