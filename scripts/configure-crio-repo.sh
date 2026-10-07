#!/usr/bin/env bash
set -euo pipefail
CRIO_VERSION="${CRIO_VERSION:-v1.37}"
KEYRING=/etc/apt/keyrings/cri-o-apt-keyring.gpg
sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL "https://download.opensuse.org/repositories/isv:/cri-o:/stable:/${CRIO_VERSION}/deb/Release.key" \
  | gpg --dearmor | sudo tee "$KEYRING" >/dev/null
echo "deb [signed-by=${KEYRING}] https://download.opensuse.org/repositories/isv:/cri-o:/stable:/${CRIO_VERSION}/deb/ /" \
  | sudo tee /etc/apt/sources.list.d/cri-o.list
sudo apt-get update
