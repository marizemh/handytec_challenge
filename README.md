# Enhanced DevOps Challenge Solution

This repository contains a production-grade DevOps solution featuring Multi-Cloud Infrastructure as Code, Advanced Kubernetes Helm Charts, System Automation, and a visual Monitoring Dashboard.

## 🚀 Features

- **Infrastructure as Code (IaC)**: Modular Terraform for AWS (EKS) and Azure (AKS).
- **Kubernetes**: Helm charts with environment-specific values (`dev`, `prod`) and Ingress with TLS.
- **Automation**: `health_check.sh` with JSON/CSV output, self-healing, and alerting.
- **Monitoring**: Custom Flask Dashboard and k6 Load Testing scripts.
- **CI/CD**: GitHub Actions for Terraform validation, App build, and K8s deployment.

## 📂 Repository Structure

```
├── infra/
│   ├── aws/            # AWS Terraform Modules (VPC, EKS, IAM)
│   ├── azure/          # Azure Terraform Modules (Placeholder for Future)
│   └── archive/        # Legacy code
├── charts/
│   └── devops-app/     # Helm Chart for the Application
├── scripts/
│   └── health_check.sh # Advanced System Health Check
├── dashboard/
│   ├── app.py          # Flask Monitoring App
│   └── load_test.js    # k6 Load Test
├── docs/               # Architecture and Guides
└── .github/workflows/  # CI/CD Pipelines
```

## 🛠 Quick Start

### Prerequisites
- Terraform >= 1.5
- kubectl & helm
- AWS CLI configured

### 1. Provision Infrastructure
```bash
cd infra/aws
terraform init
terraform apply -var="environment=dev"
```

### 2. Deploy Application
```bash
helm upgrade --install devops-app ./charts/devops-app -f ./charts/devops-app/values-dev.yaml
```

### 3. Run Health Check
```bash
./scripts/health_check.sh --json --fix
```

## 📊 Monitoring Dashboard

The dashboard provides real-time metrics of the host VM.
To run locally:
```bash
cd dashboard
pip install -r requirements.txt
python app.py
```
Visit `http://localhost:5000`.

## 🧪 CI/CD

- **CI Infra**: Validates Terraform and runs security scans (checkov).
- **CI App**: Builds Docker image and lints Helm charts.
- **CD Deploy**: Auto-deploys to EKS on push to `main`.

## 📈 Cost Optimization Tips
- **Spot Instances**: Use Spot instances for EKS node groups in Dev.
- **Auto-scaling**: HPA is enabled to scale down replicas during low traffic.
- **Clean up**: `terraform destroy` when not in use.

## 🐛 Troubleshooting
- **Pod Pending**: Check `kubectl describe pod` for resource limits or node selectors.
- **Ingress 404**: Ensure the Ingress Controller is installed and DNS is propagated.
