variable "project_name" {
  description = "Name used to identify project resources"
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_arn" {
  description = "Arn of the EKS cluster"
  type        = string
}

variable "github_oidc_subject" {
  description = "GitHub OIDC subject allowed to assume the IAM role"
  type        = string
}

variable "eks_namespace" {
  description = "Kubernetes namespace GitHub Actions can modify"
  type        = string
  default     = "default"
}

variable "namespace" {
  description = "Kubernetes namespace GitHub Actions can modify"
  type        = string
  default     = "default"
}
