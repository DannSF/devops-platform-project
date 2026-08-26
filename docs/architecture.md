# Architecture

## Project Overview

The DevOps Platform Project demonstrates the lifecycle of building, testing,
containerizing, and deploying a Node.js application to Kubernetes on AWS.

The infrastructure is provisioned using Terraform, while GitHub Actions
automates the CI/CD pipeline.

## Architecture Overview

The project consists of three main layers:

1. CI/CD
2. AWS infrastructure
3. Kubernetes workloads

### CI/CD Flow

```text
Developer
    |
    | git push
    v
GitHub
    |
    v
GitHub Actions
    |
    +---------------------------+
    |                           |
    v                           v
Terraform Validation       Build & Test
    |                           |
    |                     Push image
    |                           |
    |                           v
    |                      Amazon ECR
    |                           |
    +-------------+-------------+
                  |
                  v
               Deploy
                  |
                  v
             Amazon EKS
```

Each Docker image is tagged using the Git commit SHA, providing traceability
between the source code commit, the image stored in Amazon ECR, and the
version deployed to Kubernetes.

GitHub Actions authenticates to AWS using OpenID Connect (OIDC). This avoids
storing long-lived AWS access keys in the repository.

Access to Kubernetes is restricted to the `devops-platform` namespace using
an EKS access entry and namespace-scoped access policy.

## AWS Infrastructure

The AWS infrastructure is provisioned with Terraform.

```text
AWS
|
+-- VPC
|   |
|   +-- Public Subnet A
|   |
|   +-- Public Subnet B
|   |
|   +-- Internet Gateway
|   |
|   +-- Public Route Table
|
+-- Amazon EKS
    |
    +-- EKS Control Plane
    |
    +-- Managed Node Group
         |
         +-- EC2 Worker Node
```

IAM roles and policies provide the EKS control plane and worker nodes with
the permissions required to interact with AWS services.

The worker node has permission to pull container images from Amazon ECR.

The Terraform configuration is organized into reusable modules:

- `network` - VPC, subnets, Internet Gateway, and routing
- `eks` - EKS cluster, managed node group, and IAM roles
- `github-oidc` - GitHub OIDC provider, IAM role, and EKS access configuration

## Kubernetes Architecture

The application runs as a Kubernetes Deployment with two replicas.

```text
Internet
    |
    v
AWS Load Balancer
    |
    v
Kubernetes Service
    |
    +----------------+
    |                |
    v                v
Application Pod   Application Pod
```

The Kubernetes Service provides a stable endpoint for the application Pods.

The application containers expose port `3000`, while the LoadBalancer Service
exposes the application externally over port `80`.

The Deployment also defines:

- Readiness probes
- Liveness probes
- CPU requests and limits
- Memory requests and limits
- Environment configuration using a ConfigMap

## Infrastructure as Code

Terraform manages the AWS infrastructure required by the project, including:

- VPC
- Public subnets
- Internet Gateway
- Route table
- IAM roles and policies
- EKS cluster
- EKS managed node group

The infrastructure can be recreated using:

```bash
terraform init
terraform plan
terraform apply
```

When the environment is no longer required, it can be removed with:

```bash
terraform destroy
```

This allows the EKS environment to be created only when needed.

## Container Registry

Amazon ECR stores the application Docker images.

GitHub Actions builds an image for each deployment and tags it using the
Git commit SHA.

Example:

```text
devops-platform-app:<git-commit-sha>
```

The EKS worker nodes retrieve these images from ECR using their IAM
permissions.

## Current State

The project currently supports:

- Containerized Node.js application
- Automated container testing
- Docker image publishing to Amazon ECR
- Kubernetes deployment on Amazon EKS
- Public access through an AWS Load Balancer
- Readiness and liveness probes
- Kubernetes resource requests and limits
- Application configuration using ConfigMap
- AWS infrastructure provisioning using Terraform
- Automated deployment to EKS using GitHub Actions
- Infrastructure destruction and recreation using Terraform
- Modular Terraform configuration
- GitHub Actions authentication using AWS OIDC
- Terraform validation in CI
- Dedicated Kubernetes namespace
- Namespace-scoped GitHub Actions permissions
- Non-root application container

## Future Improvements

Potential improvements include:

- GitHub Actions authentication to AWS using OIDC
- GitOps deployment using Argo CD or Flux
- HTTPS using ACM and a custom domain
- Kubernetes rollback testing
- Prometheus and Grafana monitoring
- Centralized logging
- Terraform remote state
- Separate development and production environments