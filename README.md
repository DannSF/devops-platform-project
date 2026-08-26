# DevOps Platform Project

A hands-on DevOps project that demonstrates how to containerize, deploy,
and automate a simple Node.js application using Docker, Kubernetes, AWS,
Terraform, and GitHub Actions.

## Architecture

The application follows this deployment flow:

GitHub
→ GitHub Actions
→ Docker
→ Amazon ECR
→ Amazon EKS
→ Kubernetes Service
→ AWS Load Balancer
→ Application Pods

Infrastructure is provisioned with Terraform and can be created and
destroyed when needed.

## Technologies

- Node.js
- Docker
- Kubernetes
- AWS ECR
- AWS EKS
- Terraform
- GitHub Actions

## Repository Structure

```text
devops-platform-project/
├── .github/
│   └── workflows/
│       └── ci.yaml                     # CI/CD pipeline
│
├── app/
│   ├── server.js                       # Node.js application
│   ├── package.json                    # Application dependencies
│   └── pnpm-lock.yaml                  # Dependency lock file
│
├── docker/
│   └── Dockerfile                      # Application container image
│
├── k8s/
│   ├── namespace.yaml                  # Application namespace
│   ├── configmap.yaml                  # Application configuration
│   ├── deployment.yaml                 # Kubernetes Deployment
│   └── service.yaml                    # LoadBalancer Service
│
├── terraform/
│   ├── modules/
│   │   ├── network/                    # VPC and networking
│   │   ├── eks/                        # EKS cluster and node group
│   │   └── github-oidc/                # GitHub Actions AWS authentication
│   ├── main.tf                         # Root module
│   ├── provider.tf                     # AWS provider
│   ├── variables.tf                    # Input variables
│   ├── terraform.tfvars                # Environment values
│   ├── outputs.tf                      # Infrastructure outputs
│   ├── versions.tf                     # Terraform/provider requirements
│   └── .terraform.lock.hcl             # Provider dependency lock
│
├── docs/
│   └── architecture.md
│
├── .dockerignore
├── .gitignore
└── README.md


## CI/CD Pipeline

The CI/CD pipeline is implemented with GitHub Actions and runs automatically
when changes are pushed to the `main` branch.

Two validation paths run before deployment:

### Terraform Validation

- Checks Terraform formatting.
- Initializes Terraform without configuring a backend.
- Validates the Terraform configuration.

### Application Build and Test

- Builds the Docker image.
- Runs the application container.
- Tests the `/` and `/health` endpoints.
- Pushes the validated image to Amazon ECR using the Git commit SHA as its tag.

The deployment job runs only after both validation jobs succeed.

### Deployment

GitHub Actions authenticates to AWS using OpenID Connect (OIDC), without
storing long-lived AWS access keys.

The deployment job:

1. Authenticates to AWS.
2. Configures access to the EKS cluster.
3. Updates the Kubernetes Deployment with the new image.
4. Waits for the Kubernetes rollout to complete.

GitHub Actions has Kubernetes edit permissions limited to the
`devops-platform` namespace.

## Infrastructure Deployment

AWS infrastructure is managed with Terraform.

To create the infrastructure:

```bash
cd terraform

terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

After the EKS cluster has been created, configure `kubectl`:

```bash
aws eks update-kubeconfig \
  --region ap-southeast-2 \
  --name devops-platform-cluster
```

Verify the worker node:

```bash
kubectl get nodes
```

## Kubernetes Deployment

The Kubernetes manifests are located in the `k8s/` directory.

Apply the application configuration and workloads:

```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

Verify the deployment:

```bash
kubectl get pods -n devops-platform
kubectl get deployments -n devops-platform
kubectl get services -n devops-platform
```

The `LoadBalancer` Service provisions an AWS load balancer that exposes the
application publicly.

The application provides two endpoints:

```text
GET /         -> Hello from DevOps Platform on EKS!
GET /health   -> {"status":"Up"}
```

## Infrastructure Cleanup

The Kubernetes LoadBalancer Service should be removed before destroying the
AWS infrastructure:

```bash
kubectl delete service devops-platform-app -n devops-platform
```

Then destroy the Terraform-managed infrastructure:

```bash
cd terraform
terraform plan -destroy
terraform destroy
```

This project intentionally supports creating and destroying the EKS
environment when needed to avoid keeping unnecessary cloud resources running.

## Architecture Documentation

A more detailed explanation of the architecture is available in
[`docs/architecture.md`](docs/architecture.md).

## Future Improvements

- Automated Kubernetes rollback strategy
- GitOps deployment using Argo CD or Flux
- HTTPS with a custom domain and AWS Certificate Manager
- Prometheus and Grafana monitoring
- Centralized logging
- Terraform remote state
- Separate development and production environments