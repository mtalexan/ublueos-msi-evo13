#!/bin/bash

set -ouex pipefail

# /opt is a symlink to /var/opt which cannot be part of the image.
# We need the content RPMs install to actually go to /usr/share/factory.
# Temporarily remove the symlink and point it to the correct location. We'll undo
# this at the end.
rm /opt
mkdir -p /usr/share/factory
ln -s /usr/share/factory /opt

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

/ctx/build_files/cloudflare_warp.sh

# tio for serial
dnf5 install -y \
    tio

    
    
# Add the nix mountpoint
install -d -m 0755 /nix


# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

#### Example for enabling a System Unit File

#systemctl enable podman.socket

### Example of preparation for installing a package that requires a symlinked directory

## /opt is symlinked to /var/opt
## for packages that require it to be writeable do the following:
#rm /opt # this is a file not a directory currently
#mkdir /opt # create the opt directory so files can be installed to it
## install package (dnf5 -y install .....)
#mv /opt /usr/share/factory # move files installed to /opt to /usr/share/factory so they will be in the final image
#ln -s /var/opt /opt # restore symlink between /var/opt and /opt again


# Undo the /opt symlink redirect we did temporarily at the start so it points to the
# correct place instead.
ln -sf /var/opt /opt