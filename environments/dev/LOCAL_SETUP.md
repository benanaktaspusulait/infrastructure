# Local Kubernetes Development Setup

This guide explains how to set up and run the infrastructure locally using Kubernetes.

## Prerequisites

1. **Docker Desktop**
   - Install [Docker Desktop](https://www.docker.com/products/docker-desktop)
   - Enable Kubernetes in Docker Desktop settings
   - Ensure Docker Desktop is running

2. **kubectl**
   - Install [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
   - Configure kubectl to use Docker Desktop:
     ```bash
     kubectl config use-context docker-desktop
     ```

3. **Helm**
   - Install [Helm](https://helm.sh/docs/intro/install/)
   - Add required repositories:
     ```bash
     helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
     helm repo add grafana https://grafana.github.io/helm-charts
     helm repo add istio https://istio-release.storage.googleapis.com/charts
     helm repo add argo https://argoproj.github.io/argo-helm
     helm repo update
     ```

4. **Terraform**
   - Install [Terraform](https://www.terraform.io/downloads.html)
   - Ensure version is >= 1.0.0

## Local Storage Setup

1. Create required directories for persistent storage:
   ```bash
   sudo mkdir -p /data/{kafka-data,redis-data,postgresql-data}
   sudo chmod -R 777 /data
   ```

## Configuration

1. **Kubernetes Context**
   - Verify your context:
     ```bash
     kubectl config get-contexts
     ```
   - The context should be `docker-desktop`

2. **Environment Variables**
   - Copy the template file:
     ```bash
     cp terraform.tfvars.template terraform.tfvars
     ```
   - Update the values in `terraform.tfvars` with your desired configuration

3. **Provider Configuration**
   - The provider configuration in each module uses:
     ```hcl
     provider "kubernetes" {
       config_path = "~/.kube/config"
       config_context = "docker-desktop"
     }
     ```
   - Update the `config_context` if you're using a different context name

## Pre-deployment Verification

1. **Verify Docker Desktop**
   ```bash
   docker ps
   docker info
   ```

2. **Verify Kubernetes Cluster**
   ```bash
   kubectl cluster-info
   kubectl get nodes
   kubectl get pods --all-namespaces
   ```

3. **Verify Helm**
   ```bash
   helm version
   helm repo list
   ```

4. **Verify Storage**
   ```bash
   ls -la /data
   ```

5. **Verify Network**
   ```bash
   kubectl get networkpolicies --all-namespaces
   ```

## Deployment

1. Initialize Terraform:
   ```bash
   terraform init
   ```

2. Plan the deployment:
   ```bash
   terraform plan
   ```

3. Apply the configuration:
   ```bash
   terraform apply
   ```

4. Verify Prometheus Operator installation:
   ```bash
   kubectl get pods -n monitoring
   kubectl get crd | grep monitoring.coreos.com
   ```

## Verification

1. Check namespaces:
   ```bash
   kubectl get namespaces
   ```

2. Check pods:
   ```bash
   kubectl get pods --all-namespaces
   ```

3. Check services:
   ```bash
   kubectl get svc --all-namespaces
   ```

4. Check ServiceMonitors:
   ```bash
   kubectl get servicemonitors --all-namespaces
   ```

## Accessing Services

1. **Grafana**
   ```bash
   kubectl port-forward svc/grafana 3000:3000 -n monitoring
   ```
   Access at: http://localhost:3000

2. **Prometheus**
   ```bash
   kubectl port-forward svc/prometheus-server 9090:9090 -n monitoring
   ```
   Access at: http://localhost:9090

3. **Alertmanager**
   ```bash
   kubectl port-forward svc/alertmanager 9093:9093 -n monitoring
   ```
   Access at: http://localhost:9093

## Troubleshooting

1. **Connection Issues**
   - Ensure Docker Desktop is running
   - Verify Kubernetes is enabled in Docker Desktop
   - Check kubectl context:
     ```bash
     kubectl config current-context
     ```
   - Verify cluster connectivity:
     ```bash
     kubectl cluster-info
     kubectl get nodes
     ```
   - Check Docker Desktop settings:
     - Open Docker Desktop
     - Go to Settings > Kubernetes
     - Ensure "Enable Kubernetes" is checked
     - Click "Apply & Restart"

2. **Storage Issues**
   - Verify storage directories exist and have correct permissions
   - Check persistent volume claims:
     ```bash
     kubectl get pvc --all-namespaces
     ```

3. **Pod Issues**
   - Check pod logs:
     ```bash
     kubectl logs <pod-name> -n <namespace>
     ```
   - Check pod events:
     ```bash
     kubectl describe pod <pod-name> -n <namespace>
     ```

4. **Monitoring Issues**
   - Check Prometheus Operator logs:
     ```bash
     kubectl logs -l app.kubernetes.io/name=prometheus-operator -n monitoring
     ```
   - Verify ServiceMonitor CRD:
     ```bash
     kubectl get crd servicemonitors.monitoring.coreos.com
     ```
   - If ServiceMonitor CRD is missing:
     ```bash
     helm install prometheus prometheus-community/kube-prometheus-stack \
       --namespace monitoring \
       --create-namespace \
       --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false
     ```

## Cleanup

To remove all resources:
```bash
terraform destroy
```

## Additional Resources

- [Docker Desktop Documentation](https://docs.docker.com/desktop/)
- [Kubernetes Documentation](https://kubernetes.io/docs/home/)
- [Terraform Documentation](https://www.terraform.io/docs/)
- [Helm Documentation](https://helm.sh/docs/)
- [Prometheus Operator Documentation](https://github.com/prometheus-operator/prometheus-operator) 