#!/usr/bin/bash
#
# There are a LOT of undocumented things that need to be cleaned up for bootc to work.

set -exou pipefail

dnf5 clean all
# this doesn't clean up for some reason
rm -rf /var/lib/dnf

# if something is in /var/etc it's going to cause a linter error but with no details
if [[ -d /usr/etc ]]; then
    find /usr/etc | sort -u
fi
