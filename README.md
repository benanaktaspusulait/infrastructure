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
   sudo mkdir -p /data/{kafka-data,redis-data,postgresql-data}
   sudo chmod 777 /data/{kafka-data,redis-data,postgresql-data}
   ```

## Deployment Steps

### 1. Infrastructure Setup

1. Initialize and apply Terraform:
   ```bash
   cd terraform/backend
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
   helm install monitoring prometheus-community/kube-prometheus-stack -n monitoring --create-namespace
   ```

2. Access monitoring dashboards:
   ```bash
   kubectl port-forward -n monitoring svc/grafana 3000:80
   kubectl port-forward -n monitoring svc/alertmanager 9093:9093
   ```

### 6. Security Setup

1. Install security tools:
   ```bash
   helm repo add falcosecurity https://falcosecurity.github.io/charts
   helm install falco falcosecurity/falco -n security --create-namespace
   ```

2. Run security scans:
   ```bash
   kubectl create job --from=cronjob/compliance-report compliance-scan
   ```

### 7. Backup Setup

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
   ```bash
   argocd app list
   ```

4. Verify monitoring:
   ```bash
   kubectl get pods -n monitoring
   ```

## Local Development Tips

1. Access services locally:
   ```bash
   # Gateway
   kubectl port-forward -n gateway svc/gateway-application 8080:8080
   
   # Frontend
   kubectl port-forward -n frontend svc/react-frontend 3000:80
   
   # Config
   kubectl port-forward -n config svc/config-application 8888:8888
   ```

2. View logs:
   ```bash
   kubectl logs -f deployment/<deployment-name> -n <namespace>
   ```

3. Debug Istio:
   ```bash
   istioctl proxy-config
   ```

4. Check ArgoCD status:
   ```bash
   argocd app get <app-name>
   ```

## Maintenance

### Regular Updates

1. Update applications:
   ```bash
   kubectl patch application <app-name> -n argocd --type merge -p '{"spec":{"source":{"targetRevision":"<new-version>"}}}'
   ```

2. Update security policies:
   ```bash
   kubectl apply -f modules/compliance/policies/
   ```

### Backup and Recovery

1. Create manual backup:
   ```bash
   velero backup create manual-backup
   ```

2. Restore from backup:
   ```bash
   velero restore create --from-backup manual-backup
   ```

## Troubleshooting

### Common Issues

1. Pod startup issues:
   ```bash
   kubectl describe pod <pod-name>
   kubectl logs <pod-name>
   ```

2. Network connectivity:
   ```bash
   kubectl exec -it <pod-name> -- nc -zv <service-name> <port>
   ```

3. Storage issues:
   ```bash
   kubectl describe pvc <pvc-name>
   ```

### Logs and Debugging

1. View application logs:
   ```bash
   kubectl logs -f deployment/<deployment-name>
   ```

2. Debug Istio:
   ```bash
   istioctl proxy-config
   ```

3. Check ArgoCD status:
   ```bash
   argocd app get <app-name>
   ```

## Contributing

1. Create a feature branch
2. Make your changes
3. Submit a pull request
4. Get code review
5. Merge after approval

## License

[Your License Here] 