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

. ../common.sh

PROG=sysroot
VER=0.5.11
PKG=ooce/developer/aarch64-sysroot
SUMMARY="$ARCH sysroot"
DESC="$SUMMARY for cross compilation"

BUILD_DEPENDS_IPS="
    ooce/developer/$ARCH-gcc$CROSSGCCVER
    ooce/developer/$ARCH-gnu-binutils
"

REPO=$GITHUB/richlowe/illumos-gate
BRANCH=arm64-gate

set_arch 64

BLDENV=./usr/src/tools/scripts/bldenv
MAKE=$USRBIN/make

# for aarch64.env
export PYTHON3VER PREFIX

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DSYSROOT=${SYSROOT#/}
"

build() {
    pushd $TMPDIR/$BUILDDIR/illumos-gate >/dev/null

    logmsg "Building 64-bit"

    logcmd $LN -s $DESTDIR/$SYSROOT $TMPDIR/$BUILDDIR/sysroot

    note -n "Building ld(1) and headers"

    logcmd $BLDENV $SRCDIR/files/$ARCH.env \
        "cd usr/src && $MAKE $MAKE_JOBS bldtools sgs" \
        || logerr "building tools failed"

    logcmd $MKDIR -p $DESTDIR/$PREFIX/bin || logerr "mkdir bin failed"
    logcmd $CP usr/src/tools/proto/root_i386-nd/opt/onbld/bin/amd64/ld \
        $DESTDIR/$PREFIX/bin/ || logerr "copying ld failed"
    logcmd $MKDIR -p $DESTDIR/$PREFIX/${LIBDIRS[$BUILD_ARCH]} \
        || logerr "mkdir lib failed"
    logcmd $RSYNC -a \
        usr/src/tools/proto/root_i386-nd/opt/onbld/lib/i386/64/ \
        $DESTDIR/$PREFIX/${LIBDIRS[$BUILD_ARCH]}/ \
        || logerr "copying libs failed"

    # we move the library directory level relative to ld(1)
    typeset rpath="\$ORIGIN/../${LIBDIRS[$BUILD_ARCH]}"
    rpath+=":/usr/gcc/$CROSSGCCVER/${LIBDIRS[$BUILD_ARCH]}"
    logcmd $ELFEDIT -e "dyn:value -s RUNPATH $rpath" $DESTDIR/$PREFIX/bin/ld
    logcmd $ELFEDIT -e "dyn:value -s RPATH $rpath" $DESTDIR/$PREFIX/bin/ld

    logcmd $MKDIR -p $DESTDIR/$SYSROOT/usr/include \
        || logerr "mkdir include failed"
    logcmd $RSYNC -a proto/root_aarch64/usr/include/ \
        $DESTDIR/$SYSROOT/usr/include/ || logerr "copying headers failed"

    logcmd $MKDIR -p $DESTDIR/$SYSROOT/usr/lib \
        || logerr "mkdir usr/lib failed"
    logcmd $MKDIR -p $DESTDIR/$SYSROOT/lib \
        || logerr "mkdir lib failed"

    for lib in crt libc librt libdl libpthread ssp_ns libm libmd libmp libnsl \
        libsocket libkstat; do

        note -n "Building $lib"

        libdir=lib/$lib
        case $lib in
            libm)
                libdir="lib/libm_aarch64"
                ;;
            libdl)
                libdir="cmd/sgs/libdl"
                ;;
        esac

        logcmd $BLDENV $SRCDIR/files/$ARCH.env \
            "cd usr/src/$libdir && $MAKE $MAKE_JOBS install" \
            || logerr "building $lib failed"

        case $lib in
            crt)
                logcmd $RSYNC -a proto/root_aarch64/usr/lib/*.o \
                    $DESTDIR/$SYSROOT/usr/lib/ || logerr "copying $lib failed"
                ;;
            ssp_ns)
                logcmd $RSYNC -a proto/root_aarch64/usr/lib/libssp* \
                    $DESTDIR/$SYSROOT/usr/lib/ || logerr "copying $lib failed"
                ;;
            libpthread)
                logcmd $RSYNC -a proto/root_aarch64/usr/lib/libposix4.* \
                    $DESTDIR/$SYSROOT/usr/lib/ \
                    || logerr "copying libposix4 failed"
                logcmd $RSYNC -a proto/root_aarch64/lib/libposix4.* \
                    $DESTDIR/$SYSROOT/lib/ || logerr "copying libposix4 failed"
                # FALLTHROUGH
                ;&
            *)
                logcmd $RSYNC -a proto/root_aarch64/usr/lib/$lib.* \
                    $DESTDIR/$SYSROOT/usr/lib/ || logerr "copying $lib failed"
                logcmd $RSYNC -a proto/root_aarch64/lib/$lib.* \
                    $DESTDIR/$SYSROOT/lib/ || logerr "copying $lib failed"
                ;;
        esac
    done

    # TODO: remove this once it's fixed in illumos-gate
    # the libmp build currently leaves a dangling symlink to the compat
    # version which we don't build for aarch64
    # unfortunately we cannot do this in local.mog as the check for dangling
    # symlinks happens before the pkgmogrify stage
    logcmd $RM $DESTDIR/$SYSROOT/usr/lib/libmp.so.1

    popd >/dev/null
}

build_manifests() {
    manifest_start $TMPDIR/manifest.linker
    manifest_add_dir $PREFIX/bin
    manifest_add_dir $PREFIX/lib .*
    manifest_add $PREFIX bin/.*
    manifest_add $PREFIX lib/.*
    manifest_finalise $TMPDIR/manifest.linker $PREFIX

    manifest_uniq $TMPDIR/manifest.{sysroot,linker}
    manifest_finalise $TMPDIR/manifest.sysroot $PREFIX
}

init
clone_github_source illumos-gate $REPO $BRANCH
patch_source
prep_build
build
build_manifests
PKG=${PKG/-sysroot/-linker} SUMMARY="$ARCH linker" \
    DESC="$ARCH linker for cross compilation" \
    make_package -seed $TMPDIR/manifest.linker
make_package -seed $TMPDIR/manifest.sysroot
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
