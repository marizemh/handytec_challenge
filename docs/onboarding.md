# 🚀 Titanium Onboarding Guide

## 🌎 Multi-Cloud Architecture
This solution spans **AWS EKS** and **Azure AKS**.
- `infra/aws`: Primary production workload.
- `infra/azure`: Disaster recovery and secondary workload.

## ⚓ GitOps Workflow
We use **ArgoCD** to sync state from this repo to the clusters.
1. **Dev**: Auto-syncs to `charts/devops-app` with `values-dev.yaml`.
2. **Prod**: Auto-syncs to `charts/devops-app` with `values-prod.yaml`.

## 🧪 Chaos Engineering
To test resilience, apply the LitmusChaos experiments:
```bash
kubectl apply -f chaos/experiments/pod-delete.yaml
```
This will randomly terminate pods to verify auto-healing.

## 🛡 Security Policy
We use **OPA/Rego** to enforce security:
- No Root containers.
- Liveness probes required.
Checked via `trivy` in CI.
