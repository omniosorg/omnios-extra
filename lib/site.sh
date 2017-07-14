# Package server URL and publisher
: ${PKGPUBLISHER:=omnios}
: ${PKGSRVR:=file://$MYDIR/../tmp.repo/}

# To create a on-disk repo in the top level of your checkout
# and publish there instead of the URI specified above.
#
omniosorg=/data/omnios-build/omniosorg
PKGSRVR=file://$omniosorg/_repo_22
TMPDIR=$omniosorg/_build_22
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
PREBUILT_ILLUMOS=/data/omnios-build/omniosorg/omnios.r151022

# These two should be uncommented and set to specific git changeset IDs
# if illumos-kvm and illumos-kvm-cmd get too far ahead of illumos-{gate,omnios}.
# NOTE -> These two values reflect the current known-to-work revisions.
# If a revision matches tip, you don't need to uncomment it.  If it is behind
# tip, you MUST uncomment it, or KVM/KVM-cmd won't build.
#KVM_ROLLBACK=43aa6602f0d68ff7e032aad06645e34e9921d976
#KVM_CMD_ROLLBACK=1c6181be55d1cadc4426069960688307a6083131
