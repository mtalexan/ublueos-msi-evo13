#!/usr/bin/bash
#
# There are a LOT of undocumented things that need to be cleaned up for bootc to work.

set -exou pipefail

dnf5 clean all
# this doesn't clean up for some reason
rm -rf /var/lib/dnf

rm -rf /tmp/*

