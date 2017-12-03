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

# Copyright 2017 OmniOS Community Edition (OmniOSce) Association.

#
# Load support functions
. ../../lib/functions.sh

BUILD_DEPENDS_IPS="
    developer/acpi/compiler
    developer/nasm
"

PROG=uefi-edk2
PKG=system/bhyve/firmware
VER=20160525
VERHUMAN=$VER
SUMMARY="UEFI-EDK2(+CSM) firmware for bhyve"
DESC="$SUMMARY"

# Respect environmental overrides for these to ease development.
: ${PKG_SOURCE_REPO:=https://github.com/omniosorg/$PROG}
: ${PKG_SOURCE_BRANCH:=bhyve/UDK2014.SP1}

# Extend VER so that the temporary build directory is branch specific.
# Branches can include '/' so remove them.
VER+="-${PKG_SOURCE_BRANCH//\//_}"

clone_source(){
    logmsg "$PROG -> $TMPDIR/$BUILDDIR/$PROG"
    logcmd mkdir -p $TMPDIR/$BUILDDIR
    pushd $TMPDIR/$BUILDDIR > /dev/null 
    if [ ! -d $PROG ]; then
        if [ -n "$EDK2_CLONE" -a -d "$EDK2_CLONE" ]; then
            logmsg "-- pulling $PROG from local clone"
            logcmd rsync -ar $EDK2_CLONE/ $PROG/
        else
            logmsg "-- cloning $PKG_SOURCE_REPO"
            logcmd $GIT clone --depth 1 -b $PKG_SOURCE_BRANCH \
                $PKG_SOURCE_REPO $PROG
        fi
    fi
    if [ -z "$EDK2_CLONE" ]; then
        logcmd $GIT -C $PROG pull || logerr "--- Failed to pull repo"
    fi
    popd > /dev/null 
}

build() {
    pushd $TMPDIR/$BUILDDIR/$PROG >/dev/null || logerr "--- chdir failed"

    export GCCPATH=/opt/gcc-4.4.4

    MAKE_ARGS="
            AS=/usr/bin/gas
            AR=/usr/bin/gar
            LD=/usr/bin/gld
            OBJCOPY=/usr/bin/gobjcopy
            CC=${GCCPATH}/bin/gcc
            CXX=${GCCPATH}/bin/g++
    "

    logmsg "-- Cleaning source tree"

    logcmd gmake $MAKE_ARGS ARCH=X64 -C BaseTools clean
    rm -f Build Conf/{target,build_rule,tools_def}.txt Conf/.cache 2>/dev/null

    logmsg "-- Building tools"

    # First build the tools. The code isn't able to detect the build
    # architecture - it doesn't expect `uname -m` to return `i86pc`
    logcmd gmake $MAKE_ARGS ARCH=X64 -C BaseTools \
        || logerr "--- BaseTools build failed"

    BUILD_ARGS="-DDEBUG_ON_SERIAL_PORT=TRUE -DFD_SIZE_2MB -DCSM_ENABLE=TRUE"

    (
        export OOGCC_BIN=$GCCPATH/bin/
        export IASL_PREFIX=/usr/sbin/
        export NASM_PREFIX=/usr/bin/i386/
        source edksetup.sh

        logmsg "-- Building compatibility support module (CSM)"
        logcmd gmake $MAKE_ARGS -C BhyvePkg/Csm/BhyveCsm16/ \
            || logerr "--- CSM build failed"

        for mode in RELEASE DEBUG; do
            logmsg "-- Building $mode firmware"
            logcmd `which build` \
                -t OOGCC -a X64 -b $mode \
                -p BhyvePkg/BhyvePkgX64.dsc \
                $BUILD_ARGS || logerr "--- $mode build failed"
        done
    ) || logerr "--- Build failed"

    popd >/dev/null
}

install() {
    pushd $TMPDIR/$BUILDDIR/$PROG >/dev/null || logerr "--- chdir failed"
    logcmd mkdir -p $DESTDIR/usr/share/bhyve/firmware
    cp OvmfPkg/License.txt $DESTDIR/LICENCE
    for mode in RELEASE DEBUG; do
        logcmd cp Build/BhyveX64/${mode}_OOGCC/FV/BHYVE.fd \
            $DESTDIR/usr/share/bhyve/firmware/BHYVE_$mode.fd
    done
    popd >/dev/null
}

init
prep_build
clone_source
build
install
# Reset version for package creation
VER=$VERHUMAN
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
