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

PROG=bazel
VER=6.3.2
PKG=ooce/developer/bazel
SUMMARY="bazel"
DESC="Build and test software of any size, quickly and reliably."

min_rel 151048
set_arch 64

JDKVER=11
JDKHOME=/usr/jdk/openjdk$JDKVER.0

RUN_DEPENDS_IPS="
    runtime/java/openjdk$JDKVER
"

# No configure
pre_configure() { false; }

post_patch() {
    pushd $TMPDIR/$BUILDDIR > /dev/null
    logcmd $SED -i "
        s%@@OOCE_JDK_HOME@@%$JDKHOME%
    " src/main/cpp/blaze_util_illumos.cc || logerr "JDKHOME subst failed"
    popd > /dev/null
}

make_arch() {
    # Several of the third party packages which are pulled in depend
    # on GNU-specific options to tools such as 'cp' and 'fgrep'
    PATH=$GNUBIN:$PATH \
        VERBOSE=yes \
        JAVA_HOME=$JDKHOME \
        EXTRA_BAZEL_ARGS=--tool_java_runtime_version=local_jdk \
        logcmd ./compile.sh || logerr "build failed"
}

post_make() {
    # It's ok if this fails, the daemon may have already stopped.
    logcmd output/bazel shutdown
}

make_install() {
    logcmd $MKDIR -p $DESTDIR/$PREFIX/bin
    logcmd $CP output/bazel $DESTDIR/$PREFIX/bin/ || logerr "Copy failed"
}

init
download_source -nodir $PROG $PROG $VER-dist
prep_build
patch_source
post_patch
build -noctf    # C++
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
