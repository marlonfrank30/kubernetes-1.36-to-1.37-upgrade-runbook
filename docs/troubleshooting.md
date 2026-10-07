# Troubleshooting

## `kubeadm upgrade apply` appears to hang

Do not immediately run a second upgrade. Inspect:

```bash
kubectl get pods -n kube-system -o wide
sudo journalctl -u kubelet -n 200 --no-pager
sudo crictl ps -a
sudo crictl pods
```

The captured session had two interrupted `kubeadm upgrade apply` attempts before a later invocation completed successfully.

## Sandbox image warning

The captured upgrade reported:

```text
detected that the sandbox image "registry.k8s.io/pause:3.10.1" ... is inconsistent ...
It is recommended to use "registry.k8s.io/pause:3.10.2"
```

Inspect the CRI-O configuration and align the pause/sandbox image with the version recommended by the Kubernetes release and runtime documentation. Do not blindly edit the runtime configuration without first confirming the active CRI-O configuration.

## Pending kernel upgrade

If `apt` reports a pending kernel upgrade:

```bash
uname -r
dpkg -l | grep -E 'linux-image|linux-modules' | tail
```

Plan a controlled reboot, then validate kubelet, CRI-O and node readiness.

## Node remains `NotReady`

```bash
kubectl describe node <NODE>
sudo systemctl status kubelet --no-pager
sudo journalctl -u kubelet -n 200 --no-pager
sudo systemctl status crio --no-pager
sudo journalctl -u crio -n 200 --no-pager
```

## Workload is already failing

Do not use the upgrade as the default explanation. Capture the pre-upgrade condition, then compare it after the upgrade:

```bash
kubectl get pods -A
kubectl describe pod <POD> -n <NAMESPACE>
kubectl logs <POD> -n <NAMESPACE> --all-containers --previous
```

The source environment already had `ves-system/ver-0` in `CrashLoopBackOff` before the upgrade sequence.
