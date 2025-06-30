#!/bin/bash

set -ouex pipefail

# /opt is a symlink to /var/opt, which isn't part of the container image, making it a broken
# symlink.  We temporarily create the destination so we can install to it, then remove it.
mkdir -p /var/opt

# Need java for the cloudflare-warp to work
dnf5 install -y \
    cloudflare-warp

# it installs into a weird place, not the correct one
mv /var/opt/cloudflare-warp/warp-svc.service /etc/systemd/system/

# enable it in the system
systemctl enable warp-svc.service

# clean up the folder that can't exist
rm -r /var/opt
