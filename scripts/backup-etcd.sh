#!/usr/bin/env bash
set -euo pipefail
OUT="${1:-/root/etcd-pre-upgrade.db}"
sudo ETCDCTL_API=3 etcdctl snapshot save "$OUT" \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key
sudo ls -lh "$OUT"
