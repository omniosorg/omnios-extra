#!/usr/bin/bash
#
# {{{ CDDL HEADER START
#
# The contents of this file are subject to the terms of the
# Common Development and Distribution License, Version 1.0 only
# (the "License").  You may not use this file except in compliance
# with the License.
#
# You can obtain a copy of the license at usr/src/OPENSOLARIS.LICENSE
# or http://www.opensolaris.org/os/licensing.
# See the License for the specific language governing permissions
# and limitations under the License.
#
# When distributing Covered Code, include this CDDL HEADER in each
# file and include the License file at usr/src/OPENSOLARIS.LICENSE.
# If applicable, add the following below this CDDL HEADER, with the
# fields enclosed by brackets "[]" replaced with your own identifying
# information: Portions Copyright [yyyy] [name of copyright owner]
#
# CDDL HEADER END }}}
#
# Copyright 2011-2013 OmniTI Computer Consulting, Inc.  All rights reserved.
# Copyright 2018 OmniOS Community Edition (OmniOSce) Association.
# Use is subject to license terms.
#
. ../../lib/functions.sh

PROG=postfix
VER=3.3.0
VERHUMAN=$VER
PKG=ooce/network/smtp/postfix
SUMMARY="Postfix MTA"
DESC="Wietse Venema's mail server alternative to sendmail"
ORIGPREFIX=$PREFIX
PREFIX=$PREFIX/$PROG
CONFPATH=/etc$PREFIX
BUILDARCH="64"
BUILD_DEPENDS_IPS="library/pcre ooce/database/bdb"

XFORM_ARGS="-D PREFIX=${PREFIX#/} -D ORIGPREFIX=${ORIGPREFIX#/} -D PROG=${PROG}"

configure64() {
    logmsg "--- configure (make makefiles)"
    logcmd $MAKE makefiles CCARGS='-m64 -DUSE_TLS -DHAS_DB -DNO_NIS \
        -DDEF_COMMAND_DIR=\"'${PREFIX}/sbin'\" \
        -DDEF_CONFIG_DIR=\"'${CONFPATH}'\" \
        -DDEF_DAEMON_DIR=\"'${PREFIX}/libexec/postfix'\" \
        -DDEF_MAILQ_PATH=\"'${PREFIX}/bin/mailq'\" \
        -DDEF_NEWALIAS_PATH=\"'${PREFIX}/bin/newaliases'\" \
        -DDEF_MANPAGE_DIR=\"'${PREFIX}/share/man'\" \
        -DDEF_SENDMAIL_PATH=\"'${PREFIX}/sbin/sendmail'\" \
        -I'${ORIGPREFIX}/include \
        AUXLIBS="-R${ORIGPREFIX}/lib/${ISAPART64} -L${ORIGPREFIX}/lib/${ISAPART64} -ldb -lssl -lcrypto" || \
            logerr "Failed make makefiles command"
}

make_clean() {
    logmsg "--- make (dist)clean"
    logcmd $MAKE tidy || \
    logcmd $MAKE -f Makefile.init makefiles || \
        logmsg "--- *** WARNING *** make (dist)clean Failed"
}

# Overriding this because "install" for postfix is interactive
make_install() {
    logmsg "--- make install"
    logcmd /bin/sh postfix-install -non-interactive install_root=${DESTDIR} || \
        logerr "--- Make install failed"

    logmsg "--- change default aliases paths"
    logcmd perl -i -pe "s!^#(alias_(?:maps|database)\\s+=\\s+hash:)/etc/aliases\$!\$1${CONFPATH}/aliases!g" \
        $DESTDIR$CONFPATH/main.cf || \
        logerr "-- modifying main.cf failed"
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
install_smf network smtp-postfix.xml
make_isa_stub
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
