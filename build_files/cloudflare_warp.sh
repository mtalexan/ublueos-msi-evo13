#!/bin/bash

set -ouex pipefail

# Requires the /opt symlink workaround so the RPM installs everything destined for /opt in
# /usr/share/factory/ instead, but has the /opt symlink restored to point at /var/opt
# by the end.

# Need java for the cloudflare-warp to work
dnf5 install -y \
    cloudflare-warp

# it installs into a weird place, not the correct one
mkdir -p /usr/lib/systemd/system/
cp /opt/cloudflare-warp/warp-svc.service /usr/lib/systemd/system/

# enable it in the system
systemctl enable warp-svc.service
