
# Keeping up-to-date with upstream illumos-gate and illumos-joyent.

## Initial repository configuration

Fork the _omniosorg/illumos-omnios_ repository to your personal GitHub profile.
Then clone it to your development machine.

```shell
$ git clone git@github.com:<github_name>/illumos-omnios.git
```

Set-up remote repositories.

```shell
$ git remote add upstream git@github.com:omniosorg/illumos-omnios.git
$ git remote add -t master upstream_gate https://github.com/illumos/illumos-gate.git
$ git remote add -t master upstream_joyent https://github.com/joyent/illumos-joyent.git
$ git remote -v
origin  git@github.com:<github_name>/illumos-omnios.git (fetch)
origin  git@github.com:<github_name>/illumos-omnios.git (push)
upstream    git@github.com:omniosorg/illumos-omnios.git (fetch)
upstream    git@github.com:omniosorg/illumos-omnios.git (push)
upstream_gate   https://github.com/illumos/illumos-gate.git (fetch)
upstream_gate   https://github.com/illumos/illumos-gate.git (push)
upstream_joyent https://github.com/joyent/illumos-joyent.git (fetch)
upstream_joyent https://github.com/joyent/illumos-joyent.git (push)
```

## Update your local repository

Update your local repository.

```shell
$ git checkout master
$ git pull upstream master

$ git checkout upstream_gate
$ git pull upstream_gate master

$ git checkout upstream_joyent
$ git pull upstream_joyent master
```

Since the upstream branches track the remotes, this should always
result in a clean working tree.

Push the upstream branches to the remote repositories.

```shell
$ git push -u upstream upstream_gate
$ git push -u upstream upstream_joyent

$ git push -u origin upstream_gate
$ git push -u origin upstream_joyent
```

## Merge upstream changes into new branch

Create a new branch into which the upstream changes will be merged in order
to create a pull request. The branch name should be
_upstream-merge/YYYYMMDDnn_ where _nn_ starts at 01 and is incremented in
the case that there is more than one merge in the same day.

```shell
$ git checkout -b upstream-merge/2017070301 master
```

Merge the upstream changes. This will either complete successfully or produce
conflicts that require manual intervention. Conflicts will be due to
OmniOS-specific changes or because of the incorporation of LX Zones and
accompanying infrastructure.

### Process for a successful merge

```shell
$ git merge upstream_gate

$ git status
On branch upstream-merge/2017070301
nothing to commit, working tree clean
```

### Process for a failed merge

```shell
$ git merge upstream_gate
Auto-merging usr/src/uts/intel/sys/ucontext.h
... additional output deleted ...
Automatic merge failed; fix conflicts and then commit the result.

$ git status
Unmerged paths:
  (use "git add <file>..." to mark resolution)

        both modified:   usr/src/head/lastlog.h
        both modified:   usr/src/man/man1m/zonecfg.1m
```

Once you have manually resolved the conflicts, add the files and commit
the change.

```shell
$ git add usr/src/head/lastlog.h
$ git add usr/src/man/man1m/zonecfg.1m
$ git commit
```

## Perform a test build

```shell
$ nightly /path/to/omnios.env
```

If the build is unsuccessful, resolve this before moving on to the next
step.

## Push the merged branch

```shell
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

As soon as your PR has been merged, head over to
[_sync-upstream-joyent.md_.](sync-upstream-joyent.md)
