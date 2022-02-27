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

# Copyright 2022 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=pg_repack
PKG=ooce/database/postgresql-XX/pg_repack
VER=1.4.7
SUMMARY="PostgreSQL XX online table repacking extension"
DESC="Reorganize tables in PostgreSQL XX databases with minimal locks"

PGVERSIONS="13 14"

DEF_BUILD_DEPENDS_IPS="
ooce/library/postgresql-XX
"
DEF_RUN_DEPENDS_IPS="
ooce/database/postgresql-XX
"

OPREFIX=$PREFIX
OPATH=$PATH

set_arch 64
set_builddir pg_repack-ver_$VER

# No configure
configure64() { :; }

for v in $PGVERSIONS; do
    BUILD_DEPENDS_IPS+=" ${DEF_BUILD_DEPENDS_IPS/XX/$v}"
done

init
download_source $PROG ver_$VER
patch_source

for v in $PGVERSIONS; do
    PREFIX=$OPREFIX/pgsql-$v

    # Make sure the right pg_config is used.
    export PATH="$PREFIX/bin:$OPATH"

    build
    PKG=${PKG/XX/$v} \
        RUN_DEPENDS_IPS=${DEF_RUN_DEPENDS_IPS/XX/$v} \
        SUMMARY=${SUMMARY/XX/$v} \
        DESC=${DESC/XX/$v} \
        XFORM_ARGS="
            -DPREFIX=${PREFIX#/}
            -DOPREFIX=${OPREFIX#/}
            -DPROG=$PROG
            -DPKGROOT=pgsql-$v
            -DMEDIATOR=postgresql -DMEDIATOR_VERSION=$v
            -DVERSION=$v
            -DsVERSION=$v
        "
        make_package
    clean_up
done

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
