#!/usr/bin/bash
#
# Based on https://github.com/bsherman/bos/blob/main/signing.sh
#
# Sets up the system container registry config in the image to use the cosign.pub
# key from the root of the repo/build context as the signature verification key
# of any images pulled from the GitHub docker registry for this repo.

set -exou pipefail

# these need to match your GitHub username and the name of this repo
readonly github_username="mtalexan"
readonly github_reponame="ublueos-msi-evo13"

# Signing
mkdir -p /etc/containers
mkdir -p /etc/pki/containers
mkdir -p /etc/containers/registries.d/

if [ -f /usr/etc/containers/policy.json ]; then
    cp /usr/etc/containers/policy.json /etc/containers/policy.json
fi

cat <<<"$(jq '.transports.docker |=. + {
   "ghcr.io/${github_username}/${github_reponame}": [
    {
        "type": "sigstoreSigned",
        "keyPath": "/etc/pki/containers/${github_username}-${github_reponame}.pub",
        "signedIdentity": {
            "type": "matchRepository"
        }
    }
]}' <"/etc/containers/policy.json")" >"/tmp/policy.json"
cp /tmp/policy.json /etc/containers/policy.json
cp /ctx/cosign.pub /etc/pki/containers/${github_username}-${github_reponame}.pub
tee /etc/containers/registries.d/${github_username}-${github_reponame}.yaml <<EOF
docker:
  ghcr.io/${github_username}/${github_reponame}:
    use-sigstore-attachments: true
EOF

mkdir -p /usr/etc/containers/
cp /etc/containers/policy.json /usr/etc/containers/policy.json
