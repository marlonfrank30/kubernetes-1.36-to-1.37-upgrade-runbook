#!/usr/bin/env bash
set -euo pipefail
TARGET_MINOR="${TARGET_MINOR:-v1.37}"
KEYRING=/etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL "https://pkgs.k8s.io/core:/stable:/${TARGET_MINOR}/deb/Release.key" \
  | sudo gpg --dearmor --yes -o "$KEYRING"
echo "deb [signed-by=${KEYRING}] https://pkgs.k8s.io/core:/stable:/${TARGET_MINOR}/deb/ /" \
  | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
