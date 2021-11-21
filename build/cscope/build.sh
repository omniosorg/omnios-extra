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
# Copyright 2020 Carsten Grzemba
# Copyright 2021 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=cscope
VER=15.9
PKG=ooce/developer/cscope
SUMMARY="Cscope is a developer's tool for browsing source code"
DESC="Cscope is a developer's tool for browsing source code. It has an "
DESC+="impeccable Unix pedigree, having been originally developed at Bell "
DESC+="Labs back in the days of the PDP-11. Cscope was part of the official "
DESC+="AT&T Unix distribution for many years, and has been used to manage "
DESC+="projects involving 20 million lines of code!"

set_arch 64

init
download_source $PROG $PROG $VER
patch_source
prep_build
build -ctf
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
