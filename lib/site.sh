# Package server URL and publisher
: ${PKGPUBLISHER:=omnios}
: ${PKGSRVR:=file://$MYDIR/../tmp.repo/}

# To create a on-disk repo in the top level of your checkout
# and publish there instead of the URI specified above.
#
omniosorg=/data/omnios-build/omniosorg
PKGSRVR=file://$omniosorg/r151022/_repo
TMPDIR=$omniosorg/r151022/_build
DTMPDIR=$TMPDIR

MIRROR=$omniosorg/mirror

case `uname -n` in
	build)
		#SKIP_KAYAK_KERNEL=1
		KAYAK_SUDO_BUILD=1
		KAYAK_IMG_DSET=data/zone/build/export/kayak_image
		;;
	bloody|omniosce)
		KAYAK_SUDO_BUILD=1
		;;
esac

# Uncommenting this line will use a pre-built illumos-omnios, instead of having
# us build it.  NOTE: A build of illumos-omnios can be launched concurrently in
# conjunction with setting this variable. See functions.sh:wait_for_prebuilt().
PREBUILT_ILLUMOS=/data/omnios-build/omniosorg/r151022/illumos

