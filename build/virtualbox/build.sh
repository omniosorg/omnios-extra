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

# Copyright 2018 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/functions.sh

PROG=VirtualBox
PKG=ooce/virtualization/virtualbox
VER=5.2.22
GSOAPVER=2.8.73
GSOAPDIR=gsoap-${GSOAPVER%.*}
SUMMARY="VirtualBox"
DESC="VirtualBox is a general-purpose full virtualiser for x86 hardware, "
DESC+="targeted at server, desktop and embedded use."

if [ $RELVER -lt 151028 ]; then
    logmsg "--- $PKG is not built for r$RELVER"
    exit 0
fi

MAJVER=${VER%.*}            # M.m
sMAJVER=${MAJVER//./}       # Mm

# Set path so that libIDL-config-2 can be found by the configure script
export PATH="$PREFIX/bin:$PATH"
export LD_LIBRARY_PATH="$PREFIX/lib/amd64"

OPREFIX=$PREFIX
PREFIX=/opt/$PROG
CONFPATH=/etc$PREFIX
LOGPATH=/var/log$OPREFIX/$PROG
VARPATH=/var$OPREFIX/$PROG
RUNPATH=$VARPATH/run

BUILD_DEPENDS_IPS="
    developer/build/onbld
    ooce/library/libidl
    ooce/library/libpng
    ooce/library/libjpeg-turbo
    ooce/library/libvncserver
    system/header/header-usb
"

# Needed for the VNC extension pack
RUN_DEPENDS_IPS="
    ooce/library/libjpeg-turbo
    ooce/library/libvncserver
"

set_arch 64

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
    -DVERSION=$MAJVER
    -DsVERSION=$sMAJVER
    -DGSOAPDIR=$GSOAPDIR
"

# The usual --prefix etc. options are not supported
CONFIGURE_OPTS_64=

init
prep_build

#########################################################################

# Download and build a static version of gsoap which is required for the
# vboxwebservice build
CONFIGURE_OPTS="
    --prefix=/usr
    --enable-ipv6
"
# gsoap does not build with parallel make
NO_PARALLEL_MAKE=1
build_dependency gsoap $GSOAPDIR gsoap gsoap_$GSOAPVER ""
NO_PARALLEL_MAKE=
LD_LIBRARY_PATH+=":$DEPROOT/usr/lib"
export LD_LIBRARY_PATH

#########################################################################

CONFIGURE_OPTS="
    --build-headless
    --build-libopus
    --disable-python
    --disable-alsa
    --disable-pulse
    --disable-dbus
    --disable-kmods
    --enable-vnc
    --enable-webservice
"

make_prog() {
    pushd $TMPDIR/$BUILDDIR > /dev/null

    cat << EOF > LocalConfig.kmk
VBOX_WITHOUT_ADDITIONS = 1
VBOX_WITH_HEADLESS = 1
VBOX_WITH_VBOXFB =
VBOX_WITH_KCHMVIEWER =
VBOX_WITH_TESTSUITE =
VBOX_WITH_TESTCASES =
VBOX_WITH_SHARED_FOLDERS =
VBOX_WITH_SHARED_CLIPBOARD =
VBOX_WITH_DEBUGGER_GUI =

VBOX_X11_SEAMLESS_GUEST =
VBOX_GCC_std = -std=c++11

VBOX_WITH_DTRACE_R3 =
VBOX_WITH_DTRACE_R3_MAIN =
VBOX_WITH_DTRACE_R0DRV =
VBOX_WITH_DTRACE_RC =
VBOX_WITH_NATIVE_DTRACE =
VBoxVNC_INCS = /opt/ooce/include

NOWEBSVC =
VBOX_WITH_WEBSERVICES = 1
VBOX_WITH_WEBSERVICES_SSL = 1
VBOX_GSOAP_INSTALLED = 1
VBOX_PATH_GSOAP = $DEPROOT/usr
VBOX_PATH_GSOAP_IMPORT = $DEPROOT/usr/share/gsoap/import
VBOX_GSOAP_CXX_SOURCES =
VBOX_GSOAP_CXX_LIBS = libgsoapssl++ libz
VBOX_GSOAP_INCS = $DEPROOT/usr/include

EOF
    logmsg "--- building VirtualBox"
    . ./env.sh
    logmsg "    BUILD TYPE: $BUILD_TYPE"
    logcmd kmk || logerr "failed build VirtualBox"
}

make_install() {
    logmsg "--- make install"
    . ./env.sh
    logcmd kmk install || logerr "--- Make install failed"

    pushd src/VBox/Installer >/dev/null
    logcmd kmk solaris-install VBOX_PATH_SI_SCRATCH_PKG=$DESTDIR \
        || logerr "--- solaris-install failed"
    popd >/dev/null

    rpath=$PREFIX/amd64:$OPREFIX/lib/amd64:/usr/gcc/$GCCVER/lib/amd64

    # Fix the runtime path for these components to include the ooce lib
    # in order that libpng can be found.
    for f in VBoxSVC components/VBoxC.so; do
        logcmd elfedit -e "dyn:value -s RUNPATH $rpath" $DESTDIR$PREFIX/amd64/$f
        logcmd elfedit -e "dyn:value -s RPATH $rpath" $DESTDIR$PREFIX/amd64/$f
    done

    # Fix the runtime path for the VNC module.
    pushd out/solaris.amd64/$BUILD_TYPE/bin/ExtensionPacks/VNC/solaris.amd64
    logcmd elfedit -e "dyn:value -s RUNPATH $rpath" VBoxVNC.so
    logcmd elfedit -e "dyn:value -s RPATH $rpath" VBoxVNC.so
    popd

    pushd src/VBox/ExtPacks/VNC >/dev/null
    logcmd kmk packing
    popd >/dev/null

    # Copy in VNC extension pack
    logcmd mkdir -p $DESTDIR$PREFIX/extpack
    logcmd cp out/solaris.amd64/$BUILD_TYPE/packages/VNC-*.vbox-extpack \
        $DESTDIR$PREFIX/extpack
}

download_source $PROG $PROG $VER
patch_source
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
