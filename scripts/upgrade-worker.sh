#!/usr/bin/env bash
set -euo pipefail
# Run this script ON ONE worker at a time, after draining it from the control plane.
TARGET="${TARGET:-1.37.1-1.1}"
sudo apt-mark unhold kubeadm kubelet kubectl
sudo apt-get update
sudo apt-get install -y "kubeadm=${TARGET}" "kubelet=${TARGET}" "kubectl=${TARGET}"
sudo kubeadm upgrade node
sudo systemctl daemon-reload
sudo systemctl restart kubelet
sudo apt-mark hold kubeadm kubelet kubectl
