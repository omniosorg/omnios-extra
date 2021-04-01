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

. ../../lib/functions.sh

PROG=sg3_utils
VER=1.46
PKG=ooce/system/sg3_utils
SUMMARY="the sg3-utils SCSI utilities"
DESC="Collection of utilities for devices that use the SCSI command set. "
DESC+="Includes utilities to copy data based on 'dd' syntax and semantics "
DESC+="(called sg_dd, sgp_dd and sgm_dd); check INQUIRY data and VPD pages "
DESC+="(sg_inq); check mode and log pages (sginfo, sg_modes and sg_logs); "
DESC+="spin up and down disks (sg_start); do self tests (sg_senddiag); "
DESC+="and various other functions. Warning: Some of these tools access "
DESC+="the internals of your system and the incorrect usage of them may "
DESC+="render your system inoperable."

OPREFIX=$PREFIX
PREFIX+=/$PROG

set_arch 64

XFORM_ARGS="
    -DOPREFIX=${OPREFIX#/}
    -DPREFIX=${PREFIX#/}
    -DPROG=$PROG
    -DPKGROOT=$PROG
"

CONFIGURE_OPTS="
    --disable-static
"

CONFIGURE_OPTS_64+="
    --libdir=$PREFIX/lib/$ISAPART64
"

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
strip_install
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
