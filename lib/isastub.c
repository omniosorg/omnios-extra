/*
 * This file and its contents are supplied under the terms of the
 * Common Development and Distribution License ("CDDL"), version 1.0.
 * You may only use this file in accordance with the terms of version
 * 1.0 of the CDDL.
 *
 * A full copy of the text of the CDDL should have accompanied this
 * source. A copy of the CDDL is also available via the Internet at
 * http://www.illumos.org/license/CDDL.
 *
 * Copyright 2011-2012 OmniTI Computer Consulting, Inc.  All rights reserved.
 * Copyright 2020 OmniOS Community Edition (OmniOSce) Association.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <limits.h>
#include <unistd.h>
#include <sys/systeminfo.h>
#include <err.h>

#if !defined(FALLBACK_PATH)
#error FALLBACK_PATH must be defined
#endif
#define Q(x) #x
#define QUOTE(x) Q(x)

int
main(int argc, char **argv, char **envp)
{
	char path[PATH_MAX], *p, *isalist;
	char isabuf[PATH_MAX];
	char trypath[PATH_MAX];
	char *bin, *isa;
	ssize_t s;

	if ((isalist = getenv("ISALIST")) == NULL) {
		int x;

		x = sysinfo(SI_ISALIST, isabuf, sizeof(isabuf));
		if (x == -1 || x > sizeof (isabuf))
			err(EXIT_FAILURE, "Could not retrieve system ISALIST");
	} else {
		/* copy it, as we're going to strtok */
		(void) strcpy(isabuf, isalist);
	}
	isalist = isabuf;

	(void) snprintf(path, sizeof(path), "/proc/%lu/path/a.out", getpid());
	s = readlink(path, trypath, sizeof(trypath));
	if (s >= 0)
		trypath[s] = '\0';

	if(s == -1 || (p = realpath(trypath, path)) == NULL) {
		strcpy(path, QUOTE(FALLBACK_PATH));
		p = path;
	}

	/* crack the path into dir and name */
	bin = strrchr(p, '/');
	if (bin == NULL)
		errx(EXIT_FAILURE, "Bad path - '%s'", p);
	*bin++ = '\0';

	isa = strtok(isalist, " ");
	do {
		(void) snprintf(trypath, sizeof(trypath), "%s/%s/%s",
		    p, isa, bin);
		if (access(trypath, X_OK) == 0) {
			execve(trypath, argv, envp);
			err(EXIT_FAILURE, "execve of %s failed", trypath);
		}
	} while ((isa = strtok(NULL, " ")) != NULL);

	errx(EXIT_FAILURE, "No ISA binaries found.");
}

