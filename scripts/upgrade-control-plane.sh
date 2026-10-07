#!/usr/bin/env bash
set -euo pipefail
TARGET="${TARGET:-1.37.1-1.1}"
TARGET_VERSION="${TARGET_VERSION:-v1.37.1}"
sudo apt-mark unhold kubeadm
sudo apt-get update
sudo apt-get install -y "kubeadm=${TARGET}"
sudo apt-mark hold kubeadm
kubeadm version
sudo kubeadm upgrade plan
sudo kubeadm upgrade apply "$TARGET_VERSION"
sudo systemctl daemon-reload
sudo systemctl restart kubelet
sudo apt-mark unhold kubelet kubectl
sudo apt-get update
sudo apt-get install -y "kubelet=${TARGET}" "kubectl=${TARGET}"
sudo apt-mark hold kubelet kubectl
