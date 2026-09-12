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
# Copyright 2026 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=sg3_utils
VER=1.49
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

test_relver '>=' 151059 && set_clangver
set_standard XPG6 CFLAGS

CONFIGURE_OPTS="
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_INSTALL_PREFIX=$PREFIX
"

pre_configure() {
    typeset arch=$1

    CONFIGURE_OPTS[$arch]="-DCMAKE_INSTALL_LIBDIR=${LIBDIRS[$arch]}"
    LDFLAGS[$arch]+=" -Wl,-R$PREFIX/${LIBDIRS[$arch]}"
}

init
download_source $PROG $PROG $VER
patch_source
prep_build cmake+ninja
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
