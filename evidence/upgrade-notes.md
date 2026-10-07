# Evidence Summary From Captured Terminal Session

Source: user-provided terminal transcript.

## Initial state

- Kubernetes client/server: `v1.36.0`
- Five nodes: `k8s-master`, `k8s-node1`–`k8s-node4`
- All nodes initially `Ready`
- CRI-O initially `1.36.0`
- Ubuntu 26.04 LTS
- Flannel CNI
- OpenEBS storage
- `ves-system/ver-0`: `16/17`, `CrashLoopBackOff`, thousands of restarts

## Upgrade planning

`kubeadm upgrade plan` showed:

- current cluster: `1.36.0`
- kubeadm: `v1.37.1`
- target: `v1.37.1`
- CoreDNS target: `v1.14.6`
- etcd target: `3.7.0-0`
- no manual kubeproxy/kubelet config conversion required

## Backup

An etcd snapshot was successfully saved:

```text
/root/etcd-pre-1.37.db
```

The reported snapshot size was approximately 25 MB.

## Control-plane result

`kubeadm upgrade apply v1.37.1` completed successfully and reported the control-plane upgrade to `v1.37.1`.

## Worker result

Worker nodes were subsequently upgraded using `kubeadm upgrade node` and Kubernetes packages at `1.37.1-1.1`.

## Runtime result

CRI-O was upgraded from 1.36.0 through the 1.37 series. The final captured node inventory reported `cri-o://1.37.2` on every node.

## Final result

All five nodes were `Ready` and `v1.37.1`.

The source transcript also showed the newer Ubuntu 26.04.1 LTS state and kernel `7.0.0-38-generic` on the control plane and most workers; node1's kernel transitioned from `7.0.0-31-generic` during the captured reboot/update sequence.

## Existing workload condition

`ves-system/ver-0` remained an important health item. The transcript shows it at `16/17 CrashLoopBackOff` before the upgrade. This repo intentionally does not claim the Kubernetes upgrade caused or fixed that application-level issue.
