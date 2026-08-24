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
│       └── ci.yaml              # CI/CD pipeline
│
├── app/
│   ├── server.js                # Node.js application
│   ├── package.json             # Application dependencies and scripts
│   └── pnpm-lock.yaml           # Dependency lock file
│
├── docker/
│   └── Dockerfile                # Application container image
│
├── k8s/
│   ├── configmap.yaml            # Application configuration
│   ├── deployment.yaml          # Kubernetes Deployment
│   ├── service.yaml             # Application Service
│   └── ingress.yaml             # Ingress configuration
│
├── terraform/
│   ├── main.tf                  # AWS infrastructure resources
│   ├── provider.tf              # AWS provider configuration
│   ├── variables.tf             # Terraform input variables
│   ├── terraform.tfvars         # Environment-specific values
│   ├── outputs.tf               # Infrastructure outputs
│   ├── versions.tf              # Terraform/provider requirements
│   └── .terraform.lock.hcl      # Provider dependency lock
│
├── docs/
│   └── architecture.md          # Architecture documentation
│
├── .dockerignore
├── .gitignore
└── README.md


## CI/CD Pipeline

The CI/CD pipeline is implemented with GitHub Actions and runs automatically
when changes are pushed to the `main` branch.

The pipeline performs the following steps:

1. Checks out the repository.
2. Authenticates with AWS.
3. Authenticates Docker with Amazon ECR.
4. Builds the application Docker image.
5. Starts the container inside the GitHub Actions runner.
6. Tests the `/` and `/health` endpoints.
7. Pushes the image to Amazon ECR using the Git commit SHA as the image tag.
8. Updates the kubeconfig for the EKS cluster.
9. Updates the Kubernetes Deployment with the new image.
10. Waits for the Kubernetes rolling update to complete.

If the application tests fail, the image is not deployed.

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
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

Verify the deployment:

```bash
kubectl get pods
kubectl get deployments
kubectl get services
```

The `LoadBalancer` Service provisions an AWS load balancer that exposes the
application publicly.

The application provides two endpoints:

```text
GET /         -> Hello from DevOps Platform!
GET /health   -> {"status":"Up"}
```

## Infrastructure Cleanup

The Kubernetes LoadBalancer Service should be removed before destroying the
AWS infrastructure:

```bash
kubectl delete service devops-platform-app
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

- AWS authentication from GitHub Actions using OIDC
- GitOps with Argo CD or Flux
- HTTPS with a custom domain and AWS Certificate Manager
- Kubernetes rollback testing
- Prometheus and Grafana monitoring
- Centralized logging
- Terraform remote state
- Separate development and production environments