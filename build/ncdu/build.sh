#!/usr/bin/bash
#
# {{{
#
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
# Copyright 2021 Oxide Computer Company
#

. ../../lib/functions.sh

PROG=ncdu
VER=1.15.1
PKG=ooce/util/ncdu
SUMMARY="$PROG - NCurses Disk Usage"
DESC='Disk usage analyzer with an ncurses interface'

set_arch 64

CPPFLAGS+=' -I/usr/include/ncurses '

init
download_source "$PROG" "$PROG" "$VER"
prep_build
build -ctf
make_package
clean_up

# vim:ts=4:sw=4:et:fdm=marker
