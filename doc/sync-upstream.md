[omniutil]: https://github.com/omniosorg/omni/

# Upstream Sync Process

This document details the steps required to keep `illumos-omnios`
up-to-date with the upstream `illumos-gate` and `illumos-joyent`
repositories using the [omni utility][omniutil].
(For a more verbose version of this document including the full equivalent
 commands, see [sync-upstream-detail.md](sync-upstream-detail.md)

## Initial repository configuration

If you haven't already, fork the
[omnisorg/illumos-omnios](https://github.com/omniosorg/illumos-omnios)
and
[omnisorg/omnios-build](https://github.com/omniosorg/omnios-build)
repositories to your personal GitHub profile.

The easiest way to then check out and configure the initial repository clones
is via the [omni utility][omniutil] setup process.

## Update your local repository

![#f03c15](https://placehold.it/15/1589f0/000000?text=+) `omni update_illumos`

Since the upstream branches track the remotes, this should always
result in a clean working tree.

## Push the upstream branches to the remote repositories.

**This is an optional step**. If you have commit access to the `omniosorg`
repositories, you can push the updated upstream branches to GitHub.
If you don't, then continue to the next step.

![#f03c15](https://placehold.it/15/1589f0/000000?text=+) `omni push_upstreams`

## Review upstream changes

The upstream changes which are not yet in `illumos-omnios` can be reviewed
via the following command:

![#f03c15](https://placehold.it/15/1589f0/000000?text=+) `omni upstream_diff`

Example output:

```
GATE:

 8598 loader: Fix BSD label partition end sector calculation.         27b4c18ac
 8608 debug.h: CTASSERT will trigger variable unused errors           f9a980108
 8473 scrub does not detect errors on active spares                   554675eee

JOYENT:

 OS-6275 lx pipe buffer is too small                                  58cb94300
          M usr/src/uts/common/brand/lx/syscall/lx_pipe.c
          M usr/src/uts/common/fs/fifofs/fifosubr.c
          M usr/src/uts/common/fs/fifofs/fifovnops.c
          M usr/src/uts/common/sys/fs/fifonode.h

 OS-6320 systemd aborts itself on suse image                          7e83ccc4c
          M usr/src/uts/common/brand/lx/io/lx_netlink.c
```

## Merge upstream illumos-gate changes into new branch

Upstream changes from `illumos-gate` will be merged into a new branch
which will be used as the basis for a pull request. The branch name is
the current date in _YYYYMMDDnn_ format where _nn_ starts at 01 and is
incremented in the case that there is more than one merge in the same day.

![#f03c15](https://placehold.it/15/1589f0/000000?text=+) `omni merge_gate`

### Process for a successful merge

If the merge is successful, you will be prompted to confirm the commit
message and, after saving, will have a clean working tree.

```
$ git status
On branch upstream-merge/2017070301
nothing to commit, working tree clean
```

### Process for a failed merge

Sometimes the merge will fail and produce conflicts which require manual
intervention.Conflicts will be due to OmniOS-specific changes or because
of the incorporation of LX Zones and accompanying infrastructure.

```
Automatic merge failed; fix conflicts and then commit the result.

$ git status
Unmerged paths:
  (use "git add <file>..." to mark resolution)

        both modified:   usr/src/head/lastlog.h
        both modified:   usr/src/man/man1m/zonecfg.1m
```

Once you have manually resolved the conflicts, add the files and commit
the change.

```
$ git add usr/src/head/lastlog.h
$ git add usr/src/man/man1m/zonecfg.1m
$ git commit
```

## Perform a test build

Following merge, perform a full test nightly build including both debug
and non-debug components

![#f03c15](https://placehold.it/15/1589f0/000000?text=+) `omni build_illumos`

or run `nightly` by hand.

```
$ nightly /path/to/omnios.env
```

**If the build is unsuccessful, resolve this before moving on to the next
step.**

## ONU to the new build

![#f03c15](https://placehold.it/15/1589f0/000000?text=+) `omni onu`

or run `onu` by hand.

```
# onu -t 20170703 -d */path/to/illumos-omnios/packages/i386/nightly-nd*
...
# init 6
```

Confirm that the system boots.

## Push the merged branch

```
$ git push -u origin upstream-merge/2017070301
Counting objects: 1224, done.
Delta compression using up to 40 threads.
Compressing objects: 100% (352/352), done.
Writing objects: 100% (1224/1224), 401.27 KiB | 0 bytes/s, done.
Total 1224 (delta 1017), reused 1022 (delta 826)
remote: Resolving deltas: 100% (1017/1017), completed with 742 local objects.
To https://github.com/<github_name>/illumos-omnios.git
 * [new branch]            upstream-merge/2017070301 -> upstream-merge/2017070301
Branch upstream-merge/2017070301 set up to track remote branch upstream-merge/2017070301 from origin.
```

## Create a pull request

Use the Github web-interface to create a pull request from the new
upstream-merge branch to the master.

* Include the `mail_msg` file from the test build;
* Review the list of commits included in this merge and include any which
are backport candidates in the description of the PR. If there are none
state that too;
* Assign reviewers and the _upstream-merge_ tag.

## Update master branch

As soon as your PR has been merged, update your master branch:

```
$ git checkout master
$ git pull upstream master
$ git push
```

## Generate list of interesting Joyent commits

![#f03c15](https://placehold.it/15/1589f0/000000?text=+) `omni lx_begin`

## Evaluate each change in turn and choose whether to pick it or not

Run `omni lx_pick` until there are no more commits remaining.

![#f03c15](https://placehold.it/15/1589f0/000000?text=+) `omni lx_pick`

If a merge fails, you will have to manually resolve it before proceeding
to the next commit.

You will eventually reach the end of the commit list and see:

```
No commits remaining.
Run 'lx_end' to finish.
```

## Clean up, update README and lx-port-data

![#f03c15](https://placehold.it/15/1589f0/000000?text=+) `omni lx_end`

## Perform a test build

```shell
$ nightly /path/to/omnios.env
```

If the build is unsuccessful, resolve this before moving on to the next
step.

## Push the merged branch

```shell
$ git push -u origin joyent-merge/2017070501
```

## Create a pull request

Use the Github web-interface to create a pull request from the new
joyent-merge branch to the master.

* Include the `mail_msg` file from the test build;
* Review the list of commits included in this merge and include any which
are backport candidates in the description of the PR. If there are none
state that too;
* Assign reviewers and the _upstream-merge_ tag.

