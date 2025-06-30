#!/bin/bash

set -ouex pipefail

# this needs to exist, but it won't be preserved for bootc
mkdir -p /opt

# Need java for the cloudflare-warp to work
dnf5 install -y \
    cloudflare-warp

# it installs into a weird place, not the correct one
mv /opt/cloudflare-warp/warp-svc.service /etc/systemd/system/

# enable it in the system
systemctl enable warp-svc.service

# clean up the folder that can't exist
rm -r /opt
