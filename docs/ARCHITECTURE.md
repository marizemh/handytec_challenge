# System Architecture

## Overview
The solution is designed to be cloud-agnostic (initially AWS) and highly scalable.

```mermaid
graph TD
    User -->|HTTPS| ALB[AWS ALB / Ingress]
    ALB -->|Route| Service[K8s Service]
    Service -->|Load Balance| Pods[Flask App Pods]
    Pods -->|Metrics| CloudWatch[AWS CloudWatch]
    
    subgraph EKS Cluster
        Pods
        HPA[Horizontal Pod Autoscaler]
    end
    
    HPA -->|Scale| Pods
    
    Dev[Developer] -->|Push| GitHub[GitHub Repo]
    GitHub -->|Trigger| Action[GitHub Actions]
    Action -->|Deploy| EKS_API[EKS API Server]
```

## Security
- **Network Policies**: Restrict pod-to-pod communication.
- **IAM Roles (IRSA)**: Pods use least-privilege IAM roles.
- **Secrets Management**: K8s Secrets (could be integrated with AWS Secrets Manager).

## Scalability
- **HPA**: auto-scales pods based on CPU/Memory.
- **CA (Cluster Autoscaler)**: auto-scales worker nodes based on pending pods.
