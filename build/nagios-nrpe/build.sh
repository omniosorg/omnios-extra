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

PROG=nagios-nrpe
VER=4.0.3
PKG=ooce/application/nagios-nrpe
SUMMARY="Nagios Remote Plugin Executor"
DESC="NRPE allows you to execute local plugins (like check_disk, \
check_procs, etc.) on remote hosts. The check_nrpe plugin is called \
from Nagios and actually makes the plugin requests to the remote host. \
Requires that nrpe be running on the remote host (either as a standalone \
daemon or as a service under inetd)."

set_arch 64

BUILDDIR=nrpe-$VER

RUN_DEPENDS_IPS="
    ooce/application/nagios-common
"

MAKE_ARGS="all"

OPREFIX=$PREFIX
PREFIX+="/nagios"

MAKE_INSTALL_ARGS="
    NRPE_INSTALL_OPTS=
    NAGIOS_INSTALL_OPTS=
"

MAKE_INSTALL_TARGET="
    install
    install-config
"

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
"

CONFIGURE_OPTS_64="
    --prefix=$PREFIX
    --bindir=$PREFIX/bin
    --with-libexecdir=$PREFIX/libexec
    --with-pluginsdir=$PREFIX/libexec
    --sysconfdir=/etc/$PREFIX
    --localstatedir=/var/$PREFIX
    --with-logdir=/var/log/$PREFIX
    --enable-command-args
"

init
download_source nagios nrpe $VER
patch_source
prep_build
build
strip_install
install_smf application nrpe.xml
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
