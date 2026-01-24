# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx
# Modified: It's idiotic to not include all the files in the build context
COPY / /

# Base Image
FROM ghcr.io/ublue-os/aurora-dx:stable
# :stable is updated weekly, :stable-daily is daily, :latest is bleeding edge unstable.
#FROM ghcr.io/ublue-os/aurora-dx:stable


## Other possible base images include:
# FROM ghcr.io/ublue-os/bazzite:latest
# FROM ghcr.io/ublue-os/bluefin-nvidia:stable
# 
# ... and so on, here are more base images
# Universal Blue Images: https://github.com/orgs/ublue-os/packages
# Fedora base image: quay.io/fedora/fedora-bootc:41
# CentOS base images: quay.io/centos-bootc/centos-bootc:stream10

### MODIFICATIONS
## make modifications desired in your image and install packages by modifying the build.sh script
## the following RUN directive does all the things required to run "build.sh" as recommended.
ARG GITHUB_USERNAME
ARG IMAGE_REGISTRY
ARG IMAGE_NAME

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build_files/signing.sh "${GITHUB_USERNAME}" "${IMAGE_REGISTRY}" "${IMAGE_NAME}" && \
    /ctx/build_files/build.sh && \
    /ctx/build_files/cleanup.sh && \
    ostree container commit
    
### LINTING
## Verify final image and contents are correct.
RUN bootc container lint