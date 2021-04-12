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

# Copyright 2011-2013 OmniTI Computer Consulting, Inc.  All rights reserved.
# Copyright 2021 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/functions.sh

PROG=postfix
VER=3.5.10
PKG=ooce/network/smtp/postfix
SUMMARY="Postfix MTA"
DESC="Wietse Venema's mail server alternative to sendmail"

set_arch 64

SKIP_LICENCES=IPL

HARDLINK_TARGETS="
    opt/ooce/postfix/libexec/postfix/smtp
    opt/ooce/postfix/libexec/postfix/qmgr
"

OPREFIX=$PREFIX
PREFIX+="/$PROG"
CONFPATH="/etc$PREFIX"

BUILD_DEPENDS_IPS="
    library/pcre
    ooce/database/bdb
    ooce/database/lmdb
    ooce/library/postgresql-${PGSQLVER//./}
    ooce/library/mariadb-${MARIASQLVER//./}
    ooce/library/security/libsasl2
"

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=${PROG}
"

SKIP_RTIME_CHECK=1

MAKE_INSTALL_TARGET=non-interactive-package

configure64() {
    logmsg "--- configure (make makefiles)"
    LIBDIR=${OPREFIX}/lib/${ISAPART64}
    logcmd $MAKE makefiles CCARGS="$CFLAGS $CFLAGS64"' \
        -DUSE_TLS -DHAS_DB -DHAS_LMDB -DNO_NIS -DHAS_LDAP \
        -DHAS_SQLITE -DHAS_MYSQL -DHAS_PGSQL -DUSE_SASL_AUTH -DUSE_CYRUS_SASL \
        -DDEF_COMMAND_DIR=\"'${PREFIX}/sbin'\" \
        -DDEF_CONFIG_DIR=\"'${CONFPATH}'\" \
        -DDEF_DAEMON_DIR=\"'${PREFIX}/libexec/postfix'\" \
        -DDEF_MAILQ_PATH=\"'${PREFIX}/bin/mailq'\" \
        -DDEF_NEWALIAS_PATH=\"'${PREFIX}/bin/newaliases'\" \
        -DDEF_MANPAGE_DIR=\"'${PREFIX}/share/man'\" \
        -DDEF_SENDMAIL_PATH=\"'${PREFIX}/sbin/sendmail'\" \
        -I'${OPREFIX}/include' \
        -I'${OPREFIX}/include/sasl' \
        -I'${OPREFIX}/mariadb-${MARIASQLVER}/include/mysql' \
        -I'${OPREFIX}/pgsql-${PGSQLVER}/include' \
        ' \
        OPT='-O2' \
        AUXLIBS="-L$LIBDIR -R$LIBDIR -ldb -lsasl2 -lssl -lcrypto" \
        AUXLIBS_LDAP="-lldap_r -llber" \
        AUXLIBS_SQLITE="-lsqlite3" \
        AUXLIBS_MYSQL="-L${OPREFIX}/mariadb-${MARIASQLVER}/lib/${ISAPART64} -R${OPREFIX}/mariadb-${MARIASQLVER}/lib/${ISAPART64} -lmysqlclient" \
        AUXLIBS_PGSQL="-L${OPREFIX}/pgsql-${PGSQLVER}/lib/${ISAPART64} -R${OPREFIX}/pgsql-${PGSQLVER}/lib/${ISAPART64} -lpq" \
        AUXLIBS_LMDB="-llmdb" \
        AUXLIBS_PCRE="-lpcre" \
            || logerr "Failed make makefiles command"
}

make_clean() {
    logmsg "--- make (dist)clean"
    logcmd $MAKE tidy || logcmd $MAKE -f Makefile.init makefiles \
        || logmsg "--- *** WARNING *** make (dist)clean Failed"
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
MAKE_INSTALL_ARGS="install_root=${DESTDIR}" build
strip_install
install_smf ooce smtp-postfix.xml
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
