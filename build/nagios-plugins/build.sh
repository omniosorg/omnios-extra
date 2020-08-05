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

# Copyright 2020 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/functions.sh

PROG=nagios-plugins
VER=2.3.3
PKG=ooce/application/nagios-plugins
SUMMARY="Plugins for Nagios"
DESC="This is the nagios-plugins package for Nagios."

set_arch 64

BUILD_DEPENDS_IPS+="
    ooce/database/mariadb-104
    ooce/database/postgresql-$PGSQLVER
"

RUN_DEPENDS_IPS+="
    ?pkg:/ooce/database/mariadb-104
    ?pkg:/ooce/database/postgresql-$PGSQLVER
    ooce/application/nagios-common
"

OPREFIX=$PREFIX
PREFIX+="/$PROG"

MAKE_INSTALL_TARGET="
    install
    install-root
"

CONFIGURE_OPTS_64="
    --prefix=$PREFIX
    --libexecdir=$OPREFIX/nagios/libexec
"

CFLAGS64+=" -I$OPREFIX/pgsql-$PGSQLVER/include"
LDFLAGS64+=" -L$OPREFIX/pgsql-$PGSQLVER/lib -R$OPREFIX/pgsql-$PGSQLVER/lib"

init
download_source nagios $PROG $VER
patch_source
prep_build
build
strip_install
make_package local.mog final.mog
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
