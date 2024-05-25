#!/usr/bin/bash
#
# {{{
# This file and its contents are supplied under the terms of the
# Common Development and Distribution License ("CDDL"), version 1.0.
# You may only use this file in accordance with the terms of version
# 1.0 of the CDDL.
#
# A full copy of the text of the CDDL should have accompanied this
# source. A copy of the CDDL is also available via the Internet at
# http://www.illumos.org/license/CDDL.
#
# }}}
#
# Copyright 2023 Carsten Grzemba
# Copyright 2024 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=squid
VER=6.9
PKG=ooce/network/proxy/squid
SUMMARY="Squid WEB Proxy"
DESC="Squid is a caching proxy for the Web supporting HTTP, HTTPS, FTP, "
DESC+="and more."

OPREFIX=$PREFIX
PREFIX+=/$PROG
CONFPATH=/etc$PREFIX
VARPATH=/var$PREFIX
LOGPATH=$VARPATH/logs
RUNPATH=$VARPATH/run
PIDFILE=$RUNPATH/squid.pid

# does not yet build with gcc 14
((GCCVER > 13)) && set_gccver 13

set_arch 64

XFORM_ARGS="
    -DOPREFIX=${OPREFIX#/}
    -DPREFIX=${PREFIX#/}
    -DPROG=$PROG
    -DPKGROOT=$PROG
    -DUSER=squid
    -DGROUP=squid
    -DPIDFILE=$PIDFILE
"

CONFIGURE_OPTS="
    --sysconfdir=$CONFPATH
    --localstatedir=$VARPATH
    --with-swapdir=$VARPATH/cache
    --with-default-user=squid
    --with-logdir=$LOGPATH
    --with-pidfile=$PIDFILE
    --enable-large-cache-files
    --disable-static
    --with-mit-krb5
    --with-ldap=/opt/ooce
    --with-build-environment=POSIX_V6_LP64_OFF64
    --with-openssl
    --enable-arp-acl
    --enable-auth
    --enable-auth-basic
    --enable-auth-digest
    --enable-auth-negotiate
    --enable-auth-ntlm
    --enable-basic-auth-helpers='DB,NCSA,YP,LDAP,PAM,getpwnam,MSNT,POP3,multi-domain-NTLM,SMB,SASL'
    --enable-cache-digests
    --enable-carp
    --enable-coss-aio-ops
    --enable-delay-pools
    --enable-digest-auth-helpers='ldap,password'
    --enable-follow-x-forwarded-for
    --enable-forward-log
    --enable-forw-via-db
    --enable-htcp
    --enable-icmp
    --enable-large-cache-files
    --enable-multicast-miss
    --enable-negotiate-auth-helpers='squid_kerb_auth'
    --enable-ntlm-auth-helpers='smb_lm,fakeauth,no_check'
    --enable-ntlm-fail-open
    --enable-referer-log
    --enable-snmp
    --enable-ssl
    --enable-ssl-crtd
    --enable-zph-qos
    --enable-icap-client
    --enable-storeio='aufs,diskd,ufs'
    --enable-storeid-rewrite-helpers=file
    --enable-inline
    --enable-useragent-log
    --enable-x-accelerator-vary
    --enable-translation
    --enable-gnuregex
    --enable-htpc
    --with-aio
    --with-tbd
    --with-aufs-threads=8
    --enable-wccp
    --enable-wccpv2
    --disable-arch-native
    --disable-esi
    ac_cv_path_krb5_config=/usr/bin/krb5-config
    squid_cv_OpenLDAP=0
"

CONFIGURE_OPTS[amd64]+="
    --libdir=$PREFIX/${LIBDIRS[amd64]}
"

CXXFLAGS+=" -Wno-unknown-pragmas -Wno-deprecated-declarations"
export LIBLDAP_LIBS="-lldap -llber"
export LIBLDAP_PATH="-L$OPREFIX/${LIBDIRS[amd64]}"
LDFLAGS[amd64]+=" -Wl,-z -Wl,ignore"
LDFLAGS[amd64]+=" -L$OPREFIX/${LIBDIRS[amd64]} -R$OPREFIX/${LIBDIRS[amd64]}"

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
xform files/$PROG > $TMPDIR/$PROG
install_execattr
install_smf -oocemethod ooce $PROG.xml $PROG
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
