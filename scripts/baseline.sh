#!/usr/bin/env bash
set -euo pipefail
kubectl version
kubectl get nodes -o wide
kubectl get pods -A
kubectl get pods -A -o wide
kubectl get --raw='/readyz?verbose'
kubeadm version
crio --version || true
uname -r
