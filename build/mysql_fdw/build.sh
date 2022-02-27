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

PROG=mysql_fdw
PKG=ooce/database/postgresql-XX/mysql_fdw
VER=2.7.0
SUMMARY="MySQL PostgreSQL XX foreign data wrapper"
DESC="Allow PostgreSQL XX to access data in a MySQL database"

PGVERSIONS="13 14"

DEF_RUN_DEPENDS_IPS="
ooce/database/postgresql-XX
ooce/library/mariadb-${MARIASQLVER//./}
"

OPREFIX=$PREFIX
OPATH=$PATH

set_arch 64
set_builddir mysql_fdw-REL-${VER//./_}

SKIP_LICENCES=modified-BSD

# No configure
configure64() { :; }

MAKE_ARGS="
USE_PGXS=1
MYSQL_LIBNAME=$OPREFIX/mariadb-$MARIASQLVER/lib/$ISAPART64/libmysqlclient.so
"

MAKE_INSTALL_ARGS="
USE_PGXS=1
"

MAKE_CLEAN_ARGS="
USE_PGXS=1
"

BUILD_DEPENDS_IPS="ooce/library/mariadb-${MARIASQLVER//./}"
for v in $PGVERSIONS; do
    BUILD_DEPENDS_IPS+=" ooce/library/postgresql-$v"
done

init
download_source $PROG REL-${VER//./_}
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
        make_package
    clean_up
done

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
