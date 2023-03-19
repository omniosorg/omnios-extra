
. ../../../lib/build.sh

ARCH=aarch64
NATIVE_TRIPLET64=${TRIPLETS[amd64]}
TRIPLET64=$ARCH-unknown-solaris2.11

if [ $RELVER -lt 151045 ]; then
    logmsg "--- The $ARCH cross packages are not built for r$RELVER"
    exit 0
fi

PREFIX=/opt/cross/$ARCH
SYSROOT=$PREFIX/sysroot

TMPDIR+="/$ARCH"
DTMPDIR+="/$ARCH"
BASE_TMPDIR=$TMPDIR

