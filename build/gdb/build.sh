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

# Copyright 2024 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=gdb
PKG=ooce/developer/gdb
VER=15.1
SUMMARY="$PROG - GNU Debugger"
DESC="The GNU debugger"

# gdb needs gdb to build - the one from the previous release is fine
BUILD_DEPENDS_IPS+=" ooce/developer/gdb"
RUN_DEPENDS_IPS+=" shell/bash"

OPREFIX=$PREFIX
PREFIX+=/$PROG

set_arch 64
# Needed for X/Open curses/termcap
set_standard -xcurses XPG6

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
    -DVERSION=$VER
    -DPKGROOT=$PROG
"

CONFIGURE_OPTS="
    --prefix=$PREFIX
    --with-x=no
    --with-curses
    --enable-plugins
    --enable-tui
    --without-auto-load-safe-path
    --with-system-zlib
    --with-python=$PYTHON
"

export CPPFLAGS+=" -D_REENTRANT -I/usr/include/gmp"

export PATH=$GNUBIN:$PATH

# gdb has large enumerations
CTF_FLAGS+=" -s"

# Generate illumos data files describing system calls and structures
# found in core files.
function generate {

    # System call table
    logmsg "--- generating system call table"
    {
        $CAT << EOM
<?xml version="1.0"?>
<!DOCTYPE feature SYSTEM "gdb-syscalls.dtd">
<syscalls_info>
EOM
        $EGREP $'^#define\tSYS_.*[0-9]$' /usr/include/sys/syscall.h \
            | while read _ call num; do
                printf '  <syscall name="%s" number="%d"/>\n' \
                    ${call#SYS_} $num
        done

        echo "</syscalls_info>"
    } > $TMPDIR/syscalls.xml
    echo $TMPDIR/syscalls.xml

    # Offset includes
    logmsg "--- generating offset information"
    pushd $TMPDIR
    for arch in $DEFAULT_ARCH; do
        logcmd $CP syscalls.xml $EXTRACTED_SRC/gdb/syscalls/$arch-illumos.xml \
            || logerr "Could not install $arch system call table"
        logcmd -p $GENOFFSETS -s $CTFSTABS -r $CTFCONVERT \
            $CW --primary gcc,$GCC,gnu --noecho -- \
            $GENOFFSETS_CFLAGS ${CFLAGS[$arch]} \
            < $SRCDIR/files/offsets.in > offsets_$arch.h
    done
    {
        $SED < offsets_i386.h 's/\t0x/_32&/'
        $SED < offsets_amd64.h 's/\t0x/_64&/'
        $EGREP $'define\tPR(FN|ARG)SZ' /usr/include/sys/old_procfs.h
    } | $TEE illumos-offsets.h > $EXTRACTED_SRC/bfd/illumos-offsets.h
    popd

    logmsg "--- building feature files"
    export XMLTOC
    logcmd $MAKE -C $TMPDIR/$EXTRACTED_SRC/gdb/features \
        GDB=$OOCEBIN/gdb \
        XMLTOC="
            i386/amd64-avx-illumos.xml
            i386/amd64-illumos.xml
            i386/i386-avx-illumos.xml
            i386/i386-illumos.xml
            i386/i386-mmx-illumos.xml
        " \
        FEATURE_XMLFILES="
            i386/32bit-illumos.xml
            i386/64bit-illumos.xml
        " \
        cfiles \
        || logerr "feature build failed"

    logmsg -n "File generation successful"
}

pre_make() {
    typeset arch=$1

    MAKE_ARGS_WS="
        CFLAGS=\"$CFLAGS ${CFLAGS[$arch]}\"
        CPPFLAGS=\"$CPPFLAGS ${CPPFLAGS[$arch]}\"
    "
}

post_make() {
    # Since we patched the doc directory out of the main makefile, build
    # the man pages separately now.
    logcmd $MAKE -C gdb/doc man install-man1 DESTDIR=$DESTDIR \
        || logerr "man build"
}

init
download_source $PROG $PROG $VER
patch_source
generate
prep_build autoconf -oot
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
