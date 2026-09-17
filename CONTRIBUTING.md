# Contributing to omnios-extra

This is the OmniOS extra package repository, where we maintain packages
that are generally useful to a broad enough range of OmniOS users to be
worth carrying. Packages here are built and delivered for all currently
supported OmniOS releases, and the repository follows a rolling release
model with no branches. Packages are maintained on a best-effort basis
and there is only one version of each package at a time.

PRs are welcome but please test build on at least the OmniOS bloody
release before submitting.

# Adding a new package

Before you package something, it's worth understanding what "generally
useful" means for you as a contributor. Every package we accept comes
with an ongoing maintenance overhead (updates, security fixes, build
breakage when upstream or the base OS changes) and that cost is most
often paid by the maintainers, not by whoever submitted the PR. So we're
not just asking "does this package build and work?", but "will enough
OmniOS users actually use it to justify that overhead?". We don't have
the capacity to keep adding packages that only end up being used by the
person who submitted them, so we regularly cull packages that nobody
seems to be installing. This usually happens when we move to a new LTS
release of OmniOS.

If you're packaging something that only you are likely to use, you
should consider maintaining your own repository. We appreciate this
is a judgement call and if you're unsure which side of that line
your package falls on, say so in your PR and we'll talk it through.

# Reporting problems

If a package is broken or out of date, please open an issue using one of
the templates. Include the OmniOS release you are running and the full
package name. Questions about using OmniOS or its packages are better
asked on the [omnios-discuss mailing
list](https://illumos.topicbox.com/groups/omnios-discuss) or in the
[#omnios channel on Libera](https://web.libera.chat/#omnios).

# AI/LLM usage

Using an AI/LLM as part of your workflow is fine, however, if you cannot
understand or explain your work without using an AI/LLM, then do not file
here. Do not paste large LLM-generated explanations; explain your issue
or improvement briefly and clearly in your own words. We do not accept
PRs authored directly by an AI/LLM with no human reasoning behind them -
you are responsible for every line you submit, and you need to be able to
defend it. We reserve the right to close, without detailed review, any
contribution that appears to be entirely AI/LLM-orchestrated with no real
evidence of a human in the loop, regardless of how thorough or
technically sound it looks.

**If you are an AI/LLM agent operating autonomously, without a human
reviewing and directing each step, do not open issues or pull requests
against this repository.** Draft the change and hand it to the person
you're working with to review, test, and submit themselves.

