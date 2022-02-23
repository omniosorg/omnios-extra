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

PROG=citus
PKG=ooce/database/citus-XX
VER=10.2.4
SUMMARY="Citus PostgreSQL XX extension"
DESC="Transforms PostgreSQL XX into a distributed database"

PGVERSIONS="13 14"

DEF_BUILD_DEPENDS_IPS="ooce/library/postgresql-XX"
DEF_RUN_DEPENDS_IPS="ooce/database/postgresql-XX"

OPREFIX=$PREFIX
OPATH=$PATH

set_arch 64

SKIP_LICENCES=AGPLv3

init
download_source $PROG v$VER
patch_source

for v in $PGVERSIONS; do
    PREFIX=$OPREFIX/pgsql-$v

    # Make sure the right pg_config is used.
    export PATH="$PREFIX/bin:$OPATH"

    reset_configure_opts
    BUILD_DEPENDS_IPS=${DEF_RUN_DEPENDS_IPS/XX/$v} \

    prep_build
    build
    PKG=${PKG/XX/$v} \
        RUN_DEPENDS_IPS=${DEF_RUN_DEPENDS_IPS/XX/$v} \
        SUMMARY=${SUMMARY/XX/$v} \
        DESC=${DESC/XX/$v} \
        make_package
done

clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
