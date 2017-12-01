#!/usr/bin/bash
#
# {{{ CDDL HEADER START
#
# The contents of this file are subject to the terms of the
# Common Development and Distribution License, Version 1.0 only
# (the "License").  You may not use this file except in compliance
# with the License.
#
# You can obtain a copy of the license at usr/src/OPENSOLARIS.LICENSE
# or http://www.opensolaris.org/os/licensing.
# See the License for the specific language governing permissions
# and limitations under the License.
#
# When distributing Covered Code, include this CDDL HEADER in each
# file and include the License file at usr/src/OPENSOLARIS.LICENSE.
# If applicable, add the following below this CDDL HEADER, with the
# fields enclosed by brackets "[]" replaced with your own identifying
# information: Portions Copyright [yyyy] [name of copyright owner]
#
# CDDL HEADER END }}}
#
# Copyright 2014 OmniTI Computer Consulting, Inc.  All rights reserved.
# Copyright 2017 OmniOS Community Edition (OmniOSce) Association.
# Use is subject to license terms.
#
# Load support functions
. ../../lib/functions.sh

PROG=texlive
VER=20170524
VERHUMAN=$VER
PKG=ooce/application/texlive
SUMMARY="TeX Live - LaTeX distribution"
DESC="$SUMMARY"

BUILD_DEPENDS_IPS="developer/pkg-config"

BUILDARCH=32

# texlive doesn't check for gmake
export MAKE

PREFIX=/opt/ooce/$PROG
reset_configure_opts

# disabling xetex as it depends on fontconfig libraries
CONFIGURE_OPTS="
    $CONFIGURE_OPTS
    --bindir=${PREFIX}/bin
    --sysconfdir=/etc${PREFIX}
    --disable-native-texlive-build
    --disable-static
    --disable-luajittex
    --disable-xetex
    --without-x
"

dl_dist() {
    pushd ${TMPDIR} >/dev/null
    for dist in texmf extra; do
        if ! [ -f ${PROG}-${VER}-${dist}.tar.xz ]; then
            logmsg "--- Downloading $dist archive"
            get_resource ${PROG}/${PROG}-${VER}-${dist}.tar.xz \
                || logerr "--- failed to download $dist"
        fi
        if ! [ -d ${PROG}-${VER}-${dist} ]; then
            logmsg "--- Extracting $dist archive"
            logcmd extract_archive ${PROG}-${VER}-${dist}.tar.xz \
                || logerr "--- failed to extract ${dist}"
        fi
    done
    popd >/dev/null
}

install_dist() {
    mkdir -p ${DESTDIR}${PREFIX}/share
    # manpages get installed from the source package into $PREFIX/share/man
    # already
    rm -rf ${TMPDIR}/${PROG}-${VER}-texmf/texmf-dist/doc/man
    # we don't want the python/ruby stuff
    logmsg "--- Copying texmf"
    logcmd cp -RP ${TMPDIR}/${PROG}-${VER}-texmf/texmf-dist ${DESTDIR}${PREFIX}/share/
    logmsg "--- Copying extra"
    logcmd cp -RP ${TMPDIR}/${PROG}-${VER}-extra/tlpkg ${DESTDIR}${PREFIX}/share/
    logcmd cp ${TMPDIR}/${PROG}-${VER}-extra/LICENSE.TL ${TMPDIR}/${BUILDDIR}/LICENSE.TL
}

config_tex() {
    dir="${DESTDIR}${PREFIX}"
    cnf="${dir}/share/texmf-dist/web2c/fmtutil.cnf"

    PATH=${dir}/bin:$PATH logcmd texlinks -f $cnf ${dir}/bin \
        || logerr '--- texlinks failed'

    # disable formats (unavailable engine)
    for f in luajittex/luajittex xetex/xetex xelatex/xetex cont-en/xetex pdfcsplain/xetex; do
        PATH=${dir}/bin:$PATH logcmd fmtutil-sys --cnffile $cnf --disablefmt $f
    done

    PATH=${dir}/bin:$PATH logcmd fmtutil-sys --cnffile $cnf --missing \
        || logerr '--- fmtutil-sys failed'
}

make_install() {
    logmsg "--- make install"
    logcmd $MAKE DESTDIR=${DESTDIR} install-strip \
        || logerr "--- Make install failed"
}

init
BUILDDIR=${PROG}-${VER}-source
download_source $PROG $PROG ${VER}-source
patch_source
dl_dist
BUILDDIR=${BUILDDIR}/build
logcmd mkdir ${TMPDIR}/$BUILDDIR
CONFIGURE_CMD=../configure
prep_build
install_dist
build
#run_testsuite check
config_tex
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
