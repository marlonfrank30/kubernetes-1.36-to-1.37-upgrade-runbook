# Pre-flight Checklist

- [ ] Confirm target minor version is supported.
- [ ] Read Kubernetes release notes and API deprecation/removal notices.
- [ ] Confirm kubeadm, kubelet and kubectl package repository is `pkgs.k8s.io`.
- [ ] Confirm CRI-O repository matches the target Kubernetes minor version.
- [ ] Verify all nodes are `Ready`.
- [ ] Verify API server health with `/readyz?verbose`.
- [ ] Record `kubectl get nodes -o wide`.
- [ ] Record `kubectl get pods -A` and identify existing failures.
- [ ] Review PodDisruptionBudgets before draining workers.
- [ ] Verify application/database backups.
- [ ] Verify etcd snapshot can be created.
- [ ] Verify CNI compatibility.
- [ ] Verify CSI/storage compatibility.
- [ ] Verify ingress/controller/operator compatibility.
- [ ] Verify F5/Volterra CE compatibility if applicable.
- [ ] Confirm enough spare capacity to drain one worker.
- [ ] Confirm maintenance/reboot access to every node.
- [ ] Confirm console/out-of-band access before upgrading the control plane.
