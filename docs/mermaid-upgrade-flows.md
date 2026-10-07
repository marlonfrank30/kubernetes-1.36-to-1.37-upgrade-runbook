# Mermaid Upgrade Flows

These diagrams are designed to make the upgrade sequence easy to review before execution. They reflect the captured **Kubernetes 1.36.0 → 1.37.1** upgrade and distinguish observed actions from recommended operational controls such as drain/uncordon.

## 1. End-to-end upgrade flow

```mermaid
flowchart TD
    A[Start: Kubernetes 1.36.0] --> B[Pre-flight health check]
    B --> C{Cluster healthy enough to proceed?}
    C -- No --> C1[Resolve or document blockers]
    C1 --> B
    C -- Yes --> D[Configure Kubernetes v1.37 repo]
    D --> E[Configure CRI-O v1.37 repo]
    E --> F[Create etcd snapshot]
    F --> G{Snapshot verified?}
    G -- No --> F
    G -- Yes --> H[Upgrade kubeadm on control plane]
    H --> I[kubeadm upgrade plan]
    I --> J{Target v1.37.1 approved?}
    J -- No --> J1[Stop / review compatibility]
    J -- Yes --> K[kubeadm upgrade apply v1.37.1]
    K --> L[Upgrade control-plane kubelet/kubectl]
    L --> M[Upgrade CRI-O]
    M --> N[Validate control plane]
    N --> O[Worker 1: drain]
    O --> P[Upgrade worker packages + CRI-O]
    P --> Q[kubeadm upgrade node]
    Q --> R[Restart services / reboot if required]
    R --> S[Validate worker]
    S --> T[Uncordon worker]
    T --> U{More workers?}
    U -- Yes --> O
    U -- No --> V[Cluster-wide validation]
    V --> W{All nodes Ready and workloads healthy?}
    W -- No --> X[Troubleshoot / rollback decision]
    W -- Yes --> Y[Upgrade complete: v1.37.1]
```

## 2. Control-plane sequence

```mermaid
sequenceDiagram
    autonumber
    participant A as Admin
    participant CP as k8s-master
    participant K as kubeadm
    participant ETCD as etcd
    participant R as CRI-O
    participant KL as kubelet

    A->>CP: Capture baseline
    A->>ETCD: Create pre-upgrade snapshot
    ETCD-->>A: /root/etcd-pre-1.37.db
    A->>CP: Upgrade kubeadm to 1.37.1
    A->>K: kubeadm upgrade plan
    K-->>A: Target v1.37.1 + component versions
    A->>K: kubeadm upgrade apply v1.37.1
    K->>ETCD: Update cluster control-plane state
    K-->>A: SUCCESS
    A->>CP: Upgrade kubelet/kubectl
    A->>R: Upgrade/restart CRI-O
    A->>KL: Restart kubelet
    KL-->>A: Control plane returns Ready
```

## 3. Worker node sequence

Run **one worker at a time** so capacity remains available.

```mermaid
flowchart LR
    A[Worker Ready] --> B[kubectl drain NODE]
    B --> C{Pods safely relocated?}
    C -- No --> D[Investigate PDBs / local storage / workloads]
    D --> B
    C -- Yes --> E[Upgrade CRI-O]
    E --> F[Upgrade kubeadm/kubelet/kubectl]
    F --> G[kubeadm upgrade node]
    G --> H[Restart CRI-O + kubelet]
    H --> I{Node Ready?}
    I -- No --> J[Inspect kubelet/runtime/events]
    J --> H
    I -- Yes --> K[Validate workloads]
    K --> L[kubectl uncordon NODE]
    L --> M[Next worker]
```

## 4. Backup and recovery decision flow

```mermaid
flowchart TD
    A[Before upgrade] --> B[etcd snapshot]
    B --> C{Snapshot successful?}
    C -- No --> D[Do not proceed]
    C -- Yes --> E[Protect / copy snapshot]
    E --> F[Perform upgrade]
    F --> G{Upgrade successful?}
    G -- Yes --> H[Run final validation]
    G -- No --> I[Capture logs + cluster state]
    I --> J{Recovery required?}
    J -- No --> K[Corrective action + retry]
    J -- Yes --> L[Use documented etcd restore procedure]
    L --> M[Rebuild / restore control-plane state as required]
    M --> N[Validate cluster]
```

> The restore branch is a **decision path**, not a claim that an etcd restore was performed during the captured upgrade.

## 5. Validation flow

```mermaid
flowchart TD
    A[Post-upgrade validation] --> B[kubectl get nodes -o wide]
    B --> C{All nodes Ready?}
    C -- No --> D[Investigate node status]
    C -- Yes --> E[Verify Kubernetes v1.37.1]
    E --> F[Verify CRI-O version]
    F --> G[Check kubelet + CRI-O services]
    G --> H[Check pods across all namespaces]
    H --> I[Check CNI / Flannel]
    I --> J[Check OpenEBS / CSI]
    J --> K[Check ingress / admission / operators]
    K --> L[Check Distributed Cloud CE workloads]
    L --> M[Check API readiness endpoint]
    M --> N{All critical services healthy?}
    N -- No --> O[Investigate application/platform health]
    N -- Yes --> P[Record final evidence]
```

## 6. Node-by-node progression

```mermaid
gantt
    title Kubernetes 1.36.0 → 1.37.1 Node Upgrade Sequence
    dateFormat  X
    axisFormat %s
    section Control Plane
    Baseline + etcd backup :done, cp1, 0, 1
    kubeadm upgrade        :done, cp2, 1, 2
    kubelet/kubectl + CRI-O:done, cp3, 2, 3
    section Worker 1
    Drain                  :done, w1a, 3, 4
    Package/runtime upgrade:done, w1b, 4, 5
    Validate + uncordon    :done, w1c, 5, 6
    section Worker 2
    Drain                  :done, w2a, 6, 7
    Package/runtime upgrade:done, w2b, 7, 8
    Validate + uncordon    :done, w2c, 8, 9
    section Worker 3
    Drain                  :done, w3a, 9, 10
    Package/runtime upgrade:done, w3b, 10, 11
    Validate + uncordon    :done, w3c, 11, 12
    section Worker 4
    Drain                  :done, w4a, 12, 13
    Package/runtime upgrade:done, w4b, 13, 14
    Validate + uncordon    :done, w4c, 14, 15
    section Final
    Cluster validation     :done, final, 15, 16
```
