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

# Copyright 2020 OmniOS Community Edition.  All rights reserved.

. ../../lib/functions.sh

PROG=nagios
VER=4.4.5
PKG=ooce/application/nagios
SUMMARY="Extremely powerful network monitoring system"
DESC="Nagios is a host and service monitor designed to inform you of network \
problems before your clients, end-users or managers do. It has been \
designed to run under the Linux operating system, but works fine under \
most *NIX variants as well. The monitoring daemon runs intermittent \
checks on hosts and services you specify using external plugins \
which return status information to Nagios. When problems are \
encountered, the daemon can send notifications out to administrative \
contacts in a variety of different ways (email, instant message, SMS, \
etc.). Current status information, historical logs, and reports can \
all be accessed via a web browser."

set_arch 64

OPREFIX=$PREFIX
PREFIX+=/$PROG

MAKE_ARGS="
    all
"

MAKE_INSTALL_ARGS="
    COMMAND_OPTS=
    INSTALL_OPTS=
"

MAKE_INSTALL_TARGET="
    install
    install-commandmode
    install-config
"

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
"

CONFIGURE_OPTS_64="
    --prefix=$PREFIX
    --sysconfdir=/etc$PREFIX
    --localstatedir=/var$PREFIX
    --with-lockfile=/var$PREFIX/run/nagios.lock
"

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
strip_install
add_notes README.install
install_smf application $PROG.xml application-$PROG
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
