#!/usr/bin/bash
#
# Based on https://github.com/bsherman/bos/blob/main/signing.sh
#
# Sets up the system container registry config in the image to use the cosign.pub
# key from the root of the repo/build context as the signature verification key
# of any images pulled from the GitHub docker registry for this repo.

set -exou pipefail

(( $# == 3 )) || { echo >&2 "Missing arguments: ${0##*/} GITHUB_USERNAME IMAGE_REGISTRY IMAGE_NAME"; exit 1; }

# lowercase the arguments
readonly github_username="${1,,}"
readonly image_registry="${2,,}"
readonly image_name="${3,,}"
export github_username image_registry image_name

[[ -n $github_username ]] || { echo >&2 "ERROR: Blank arg 1"; exit 1; }
[[ -n $image_registry ]] || { echo >&2 "ERROR: Blank arg 2"; exit 1; }
[[ -n $image_name ]] || { echo >&2 "ERROR: Blank arg 3"; exit 1; }

# Basename w/o suffix of YAML container registry config file, and the copied cosign.pub file
readonly signing_key_file_basename="${github_username}-${image_name}"
export signing_key_file_basename

# Signing
mkdir -p /etc/containers
mkdir -p /etc/pki/containers
mkdir -p /etc/containers/registries.d/

# add the cosign.pub as the properly named signing key
cp /ctx/cosign.pub "/etc/pki/containers/${signing_key_file_basename}.pub"

if [ -f /usr/etc/containers/policy.json ]; then
    cp /usr/etc/containers/policy.json /etc/containers/policy.json
fi

# Add to the policy.json file (updating if it exists, otherwise creating).
# Add the block that sets our signing key for images from our registry
cat <<<"$(jq '.transports.docker |=. + {
   "${image_registry}": [
    {
        "type": "sigstoreSigned",
        "keyPath": "/etc/pki/containers/${signing_key_file_basename}.pub",
        "signedIdentity": {
            "type": "matchRepository"
        }
    }
]}' <"/etc/containers/policy.json")" >"/tmp/policy.json"
cp /tmp/policy.json /etc/containers/policy.json

# Add a YAML file to configure using sigstore (cosign) attachments for the signing key
tee /etc/containers/registries.d/${signing_key_file_basename}.yaml <<EOF
docker:
  ${image_registry}:
    use-sigstore-attachments: true
EOF

#mkdir -p /usr/etc/containers/
#cp /etc/containers/policy.json /usr/etc/containers/policy.json
