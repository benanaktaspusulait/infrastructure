# Infrastructure Project

This repository contains the infrastructure code for the project, including Terraform configurations, Helm charts, and Kubernetes manifests.

## Project Overview

The project consists of:
- Backend Services:
  - Gateway Application (Spring Cloud Gateway)
  - Config Application (Spring Cloud Config Server)
  - FYS API (Spring Boot)
  - Stok API (Spring Boot)
- Frontend:
  - React Application
- Infrastructure Services:
  - Kafka (Message Broker)
  - Redis (Cache)
  - PostgreSQL (Database)
- Service Mesh:
  - Istio
- GitOps:
  - ArgoCD
- Infrastructure as Code:
  - Terraform
- Security:
  - Falco
  - OPA Gatekeeper
  - Trivy
- Backup:
  - Velero

## Project Structure

```
.
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── terraform.tfvars
│   │   ├── terraform.tfvars.template
│   │   ├── LOCAL_SETUP.md
│   │   └── SECURITY.md
│   ├── test/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── terraform.tfvars
│   ├── preprod/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── terraform.tfvars
│   └── prod/
│       ├── main.tf
│       ├── variables.tf
│       └── terraform.tfvars
├── modules/
│   ├── kubernetes/
│   ├── networking/
│   ├── storage/
│   ├── monitoring/
│   ├── security/
│   ├── backup/
│   └── compliance/
└── helm/
    ├── argocd/
    ├── istio/
    └── applications/
```

## Environment Structure

The project supports multiple environments:
- Development (dev)
- Testing (test)
- Pre-production (preprod)
- Production (prod)

## Prerequisites

### macOS Installation (using Homebrew)

1. Install Homebrew if not already installed:
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

2. Install Docker Desktop:
   ```bash
   brew install --cask docker
   ```
   After installation:
   - Open Docker Desktop
   - Go to Settings > Kubernetes
   - Enable Kubernetes
   - Click "Apply & Restart"

3. Install kubectl:
   ```bash
   brew install kubectl
   ```

4. Install Helm:
   ```bash
   brew install helm
   ```

5. Install ArgoCD CLI:
   ```bash
   brew install argocd
   ```

6. Install Istio:
   ```bash
   brew install istioctl
   ```

7. Install Velero:
   ```bash
   brew install velero
   ```

8. Install Trivy:
   ```bash
   brew install trivy
   ```

9. Install Terraform:
   ```bash
   brew install terraform
   ```

### Verify Installations

1. Check Docker and Kubernetes:
   ```bash
   docker --version
   kubectl version --client
   kubectl cluster-info
   ```

2. Check other tools:
   ```bash
   helm version
   argocd version --client
   istioctl version
   velero version --client
   trivy --version
   terraform --version
   ```

## Local Development Setup

1. Start Docker Desktop and enable Kubernetes
2. Verify Kubernetes is running:
   ```bash
   kubectl cluster-info
   ```

3. Create required directories for persistent storage:
   ```bash
   sudo mkdir -p /data/{kafka,redis,postgresql}
   sudo chmod 777 /data/{kafka,redis,postgresql}
   ```

## Deployment Steps

### 1. Infrastructure Setup

1. Initialize and apply Terraform for your environment:
   ```bash
   cd environments/dev
   terraform init
   terraform plan
   terraform apply
   ```

2. Verify resources:
   ```bash
   kubectl get namespaces
   kubectl get storageclass
   kubectl get pv
   ```

### 2. Service Mesh Setup

1. Install Istio:
   ```bash
   istioctl install --set profile=default
   ```

2. Enable automatic sidecar injection for namespaces:
   ```bash
   kubectl label namespace gateway istio-injection=enabled
   kubectl label namespace config istio-injection=enabled
   kubectl label namespace fys istio-injection=enabled
   kubectl label namespace stok istio-injection=enabled
   kubectl label namespace frontend istio-injection=enabled
   ```

### 3. GitOps Setup

1. Install ArgoCD:
   ```bash
   helm repo add argo https://argoproj.github.io/argo-helm
   helm install argocd argo/argo-cd -n argocd --create-namespace
   ```

2. Wait for ArgoCD to be ready:
   ```bash
   kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n argocd
   ```

3. Get ArgoCD admin password:
   ```bash
   kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
   ```

4. Apply ArgoCD applications:
   ```bash
   kubectl apply -f helm/argocd/applications/applications.yaml
   ```

### 4. Network Policies

Network policies are automatically applied by ArgoCD. The policies enforce:

1. Gateway Application:
   - Accepts traffic from frontend and local network
   - Can communicate with config, fys, and stok services

2. Config Application:
   - Accepts traffic from gateway, fys, and stok services
   - Can communicate with local Git repositories

3. FYS API:
   - Accepts traffic from gateway
   - Can communicate with config, kafka, redis, and postgresql

4. Stok API:
   - Accepts traffic from gateway
   - Can communicate with config, kafka, redis, and postgresql

5. React Frontend:
   - Accepts traffic from local network
   - Can communicate with gateway

### 5. Monitoring Setup

1. Install monitoring stack:
   ```bash
   helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
   helm repo update
   helm install prometheus prometheus-community/kube-prometheus-stack -n monitoring --create-namespace
   ```

2. Access Prometheus:
   ```bash
   kubectl port-forward svc/prometheus-kube-prometheus-prometheus 9090:9090 -n monitoring
   ```
   Then open http://localhost:9090 in your browser

3. Access Grafana:
   ```bash
   kubectl port-forward svc/prometheus-grafana 3000:80 -n monitoring
   ```
   Then open http://localhost:3000 in your browser
   - Default username: admin
   - Default password: prom-operator

4. Access Alert Manager:
   ```bash
   kubectl port-forward svc/prometheus-kube-prometheus-alertmanager 9093:9093 -n monitoring
   ```
   Then open http://localhost:9093 in your browser

### 6. Kubernetes Dashboard

1. Install Kubernetes Dashboard:
   ```bash
   kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml
   ```

2. Create a dashboard admin user:
   ```bash
   kubectl apply -f helm/applications/dashboard-admin.yaml
   ```

3. Get the admin token:
   ```bash
   kubectl -n kubernetes-dashboard get secret $(kubectl -n kubernetes-dashboard get sa/admin-user -o jsonpath="{.secrets[0].name}") -o go-template="{{.data.token | base64decode}}"
   ```

4. Access the dashboard:
   ```bash
   kubectl port-forward svc/kubernetes-dashboard 8443:443 -n kubernetes-dashboard
   ```
   Then open https://localhost:8443 in your browser
   - Accept the self-signed certificate warning
   - Use the token from step 3 to log in

### 7. Monitoring Metrics

The following metrics are available for monitoring:

1. Gateway Application:
   - Request count and latency
   - Error rates
   - Circuit breaker status
   - Route statistics

2. Config Application:
   - Configuration refresh events
   - Repository sync status
   - Error rates

3. FYS and Stok APIs:
   - Request count and latency
   - Error rates
   - Database connection status
   - Cache hit/miss rates

4. Infrastructure:
   - Node status and resources
   - Pod status and resources
   - Service health
   - Network traffic

### 8. Alerts

The following alerts are configured:

1. High-Level Alerts:
   - Pod crash loops
   - High error rates
   - Resource usage thresholds
   - Service availability

2. Business Metrics:
   - API response times
   - Error rates by service
   - Database connection issues
   - Cache performance

3. Infrastructure:
   - Node health
   - Disk space
   - Memory pressure
   - Network issues

### 9. Security Setup

1. Install security tools:
   ```bash
   helm repo add falcosecurity https://falcosecurity.github.io/charts
   helm install falco falcosecurity/falco -n security --create-namespace
   ```

2. Run security scans:
   ```bash
   kubectl create job --from=cronjob/compliance-report compliance-scan
   ```

### 10. Backup Setup

1. Configure Velero for local storage:
   ```bash
   velero install \
     --provider local \
     --plugins velero/velero-plugin-for-local:v1.5.0 \
     --backup-location-config path=/data/backups \
     --snapshot-location-config path=/data/snapshots
   ```

2. Create backup schedule:
   ```bash
   velero schedule create daily-backup --schedule="0 1 * * *"
   ```

## Verification Steps

1. Check application status:
   ```bash
   kubectl get pods -n gateway
   kubectl get pods -n config
   kubectl get pods -n fys
   kubectl get pods -n stok
   kubectl get pods -n frontend
   ```

2. Verify network policies:
   ```bash
   kubectl get networkpolicies --all-namespaces
   ```

3. Check ArgoCD sync status:
   ```