# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx
# Modified: It's idiotic to not include all the files in the build context
COPY / /

# Base Image
FROM ghcr.io/ublue-os/aurora-dx:stable-daily

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
    [[ -n "${GITHUB_USERNAME}" ]] || { echo >&2 "ERROR: Missing ARG GITHUB_USERNAME"; exit 1; }; \
    [[ -n "${IMAGE_REGISTRY}" ]] || { echo >&2 "ERROR: Missing ARG IMAGE_REGISTRY"; exit 1; }; \
    [[ -n "${IMAGE_NAME}" ]] || { echo >&2 "ERROR: Missing ARG IMAGE_NAME"; exit 1; }; \
    echo "GITHUB_USERNAME='${GITHUB_USERNAME}'"; \
    echo "IMAGE_REGISTRY='${IMAGE_REGISTRY}'"; \
    echo "IMAGE_NAME='${IMAGE_NAME}'"; \
    /ctx/build_files/signing.sh "${GITHUB_USERNAME}" "${IMAGE_REGISTRY}" "${IMAGE_NAME}" && \
    /ctx/build_files/build.sh && \
    ostree container commit
    
### LINTING
## Verify final image and contents are correct.
RUN bootc container lint