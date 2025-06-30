#!/bin/bash

set -ouex pipefail

# recursively copy everything from system_config/ in the build context to the root of the repo.
pushd /ctx/system_config
rsync -rvK . /
popd

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

# Install KDE extras
dnf5 install -y \
    imsettings-plasma \
    kclock-plasma-applet \
    marble-plasma \
    plasma-discover-offline-updates \
    plasma-discover-rpm-ostree \
    plasma-discover-snap
    
# Need java for the cloudflare-warp to work
dnf5 install -y \
    java-11-openjdk \
    cloudflare-warp

# tio for serial
dnf5 install -y \
    tio
    
# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

#### Example for enabling a System Unit File

#systemctl enable podman.socket

# Add the nix mountpoint
install -d -m 0755 /nix


# Adds the cosign.pub as the signing key for verifying bootc images pulled from this repo.
/ctx/build_files/signing.sh
