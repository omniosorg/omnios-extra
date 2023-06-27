
. ../../../lib/build.sh

ARCH=aarch64
NATIVE_TRIPLET64=${TRIPLETS[amd64]}
TRIPLET64=$ARCH-unknown-solaris2.11

min_rel 151045

PREFIX=/opt/cross/$ARCH
SYSROOT=$PREFIX/sysroot

TMPDIR+="/$ARCH"
DTMPDIR+="/$ARCH"
BASE_TMPDIR=$TMPDIR

