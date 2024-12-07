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
# Copyright 2024 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=postfix
VER=3.9.1
PKG=ooce/network/smtp/postfix
SUMMARY="Postfix MTA"
DESC="Wietse Venema's mail server alternative to sendmail"

set_arch 64
set_clangver

SKIP_LICENCES=IPL

HARDLINK_TARGETS="
    opt/ooce/postfix/libexec/postfix/smtp
    opt/ooce/postfix/libexec/postfix/qmgr
"

OPREFIX=$PREFIX
PREFIX+="/$PROG"
CONFPATH="/etc$PREFIX"

# The icu4c ABI changes frequently. Lock the version
# pulled into each build of postfix.
ICUVER=`pkg_ver icu4c`
ICUVER=${ICUVER%%.*}
BUILD_DEPENDS_IPS="
    library/pcre2
    ooce/database/bdb
    ooce/database/lmdb
    =ooce/library/icu4c@$ICUVER
    ooce/library/postgresql-${PGSQLVER//./}
    ooce/library/mariadb-${MARIASQLVER//./}
    ooce/library/security/libsasl2
"
RUN_DEPENDS_IPS="=ooce/library/icu4c@$ICUVER"

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=${PROG}
"

SKIP_RTIME_CHECK=1

MAKE_INSTALL_TARGET=non-interactive-package

pre_configure() {
    typeset arch=$1

    if cross_arch $arch; then
        save_variable BUILDARCH
        set_arch $BUILD_ARCH
        set_gccver $DEFAULT_GCC_VER

        note -n "-- Building native tools"

        pushd $TMPDIR/$BUILDDIR >/dev/null

        # we don't really care about the configure options here as we just need
        # a native postconf; however, postconf decides where to install
        # everything, so it should know about the proper locations
        logcmd $MAKE makefiles CCARGS="$CFLAGS"' \
            -DDEF_COMMAND_DIR=\"'${PREFIX}/sbin'\" \
            -DDEF_CONFIG_DIR=\"'${CONFPATH}'\" \
            -DDEF_DAEMON_DIR=\"'${PREFIX}/libexec/postfix'\" \
            -DDEF_MAILQ_PATH=\"'${PREFIX}/bin/mailq'\" \
            -DDEF_NEWALIAS_PATH=\"'${PREFIX}/bin/newaliases'\" \
            -DDEF_MANPAGE_DIR=\"'${PREFIX}/share/man'\" \
            -DDEF_SENDMAIL_PATH=\"'${PREFIX}/sbin/sendmail'\" \
            ' || logerr "failed making native makefiles"

        logcmd $MAKE $MAKE_JOBS || logerr "failed to make native tools"
        logcmd $CP $TMPDIR/$BUILDDIR/bin/postconf $TMPDIR/ \
            || logerr "failed to copy native postconf"

        popd >/dev/null

        set_crossgcc $arch
        restore_variable BUILDARCH

        note -n "-- Building $PROG"

        make_clean $arch
    fi

    logmsg "--- configure (make makefiles)"

    ARCHLIB=${LIBDIRS[$arch]}
    LIBDIR=$OPREFIX/$ARCHLIB
    # help makedefs to find and successfully build a test program linking libicu
    addpath PKG_CONFIG_PATH "$PKG_CONFIG_PATH[$arch]"
    export PKG_CONFIG_PATH

    logcmd $MAKE makefiles CCARGS="$CFLAGS ${CFLAGS[$arch]}"' \
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
        AUXLIBS="-L${SYSROOT[$arch]}$LIBDIR -Wl,-R$LIBDIR -ldb -lsasl2 -lssl -lcrypto" \
        AUXLIBS_LDAP="-lldap_r -llber" \
        AUXLIBS_SQLITE="-lsqlite3" \
        AUXLIBS_MYSQL="-L${SYSROOT[$arch]}${OPREFIX}/mariadb-${MARIASQLVER}/$ARCHLIB -Wl,-R${OPREFIX}/mariadb-${MARIASQLVER}/$ARCHLIB -lmysqlclient" \
        AUXLIBS_PGSQL="-L${SYSROOT[$arch]}${OPREFIX}/pgsql-${PGSQLVER}/$ARCHLIB -Wl,-R${OPREFIX}/pgsql-${PGSQLVER}/$ARCHLIB -lpq" \
        AUXLIBS_LMDB="-llmdb" \
        AUXLIBS_PCRE="-lpcre2" \
            || logerr "Failed make makefiles command"

    false
}

pre_install() {
    typeset arch=$1

    MAKE_INSTALL_ARGS="install_root=${DESTDIR}"

    ! cross_arch $arch && return

    export POSTCONF=$TMPDIR/postconf
}

post_install() {
    install_smf ooce smtp-postfix.xml
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
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
